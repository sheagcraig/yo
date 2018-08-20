#!/usr/bin/python
# Copyright 2014-2017 Shea G. Craig
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.
"""Manage Yo notifications

This tool helps schedule yo notifications. It solves several problems
for administrators.

First, it ensures that the proper application context is available prior
to attempting to run the yo binary, which will fail if not run as the
current console user.

The scheduler ensures that any notification is delivered at least once
to each user. If they are not logged in when configured, the
notification will be delivered immediately after their next login.

Admins may specify a date after which notifications are no-longer
considered deliverable, ensuring notifications aren't delivered to
infrequently used accounts long-past their freshness date.

Likewise, a list of accounts for which delivering notifications should
be skipped may be specified on a per-notification and a global basis.

Normally, the tool must be run as root. For testing purposes,  you may
trigger a notification for the current console user by running this tool
with that user's account.

Unless cleared, the `com.sheagcraig.yo` preference domain caches
all notifications so that they may be delivered to any user of the
system without foreknowledge of their username, infinitely into the
future. The yo_scheduler includes a flag to clear cached notifications
while retaining any other preferences.
"""


import argparse
import os
from subprocess import call
import sys
import time

# pylint: disable=import-error
from Foundation import (
    CFPreferencesAppSynchronize, CFPreferencesCopyAppValue,
    CFPreferencesCopyValue, CFPreferencesSetAppValue, CFPreferencesSetValue,
    kCFPreferencesAnyHost, kCFPreferencesAnyUser, NSDate)
from SystemConfiguration import SCDynamicStoreCopyConsoleUser
# pylint: enable=import-error


__version__ = "2.0.0"
BUNDLE_ID = "com.sheagcraig.yo"
WATCH_PATH = "/private/tmp/.com.sheagcraig.yo.on_demand.launchd"
YO_BINARY = "/Applications/Utilities/yo.app/Contents/MacOS/yo"
# This is captured straight from running the Yo binary and must be
# updated manually.
YO_HELP = """\
    Yo app notification options:
    -t, --title:
        Title for notification. REQUIRED.
    -s, --subtitle:
        Subtitle for notification.
    -n, --info:
        Informative text.
    -b, --action-btn:
        Include an action button, with the button label text supplied to this
        argument.
    -a, --action-path:
        Application to open if user selects the action button. Provide the full
        path as the argument. This option only does something if
        -b/--action-btn is also specified.
    -B, --bash-action:
        Bash script to run. Be sure to properly escape all reserved characters.
        This option only does something if -b/--action-btn is also specified.
        Defaults to opening nothing.
    -o, --other-btn:
        Alternate label for cancel button text.
    -i, --icon:
        Complete path to an alternate icon to use for the notification.
    -c, --content-image:
        Path to an image to use for the notification's 'contentImage' property.
    -z, --delivery-sound:
        The name of the sound to play when delivering or 'None'. The name must
        not include the extension, nor any path components, and should be
        located in '/Library/Sounds' or '~/Library/Sounds'. (Defaults to the
        system's default notification sound). See the README for more info.
    -d, --ignores-do-not-disturb:
        Set to make your notification appear even if computer is in
        do-not-disturb mode.
    -l, --lockscreen-only:
        Set to make your notification appear only if computer is locked. If
        set, no buttons will be available.
    -p, --poofs-on-cancel:
        Set to make your notification 'poof' when the cancel button is hit.
    -m, --banner-mode:
        Does not work! Set if you would like to send a non-persistent
        notification. No buttons will be available if set.
    -v, --version:
        Display Yo version information."""


def main():
    """Application main"""
    # Capture commandline args.
    parser = get_argument_parser()
    # Use the parse_known_args method to automatically separate out the
    # yo_scheduler (this script) args from the yo app's args.
    launcher_args, yo_args = parser.parse_known_args()

    if any(flag in yo_args for flag in ("--version", "-v")):
        # Skip further checks if version is requested.
        run_yo_with_args(yo_args)

    elif launcher_args.cached:
        # Yo is being run by a LaunchAgent for the current console user.
        # Post all of the stored notifications!
        process_notifications()

    elif launcher_args.cleanup:
        # Yo is being called by the cleanup LaunchDaemon.
        exit_if_not_root()
        clear_scheduled_notifications()

    elif not is_console_user():
        # Schedule notifications for delivery.
        # Yo is being called by someone other than the logged in console
        # user. Check for root privileges, and cache notifications.
        exit_if_not_root()
        schedule_notification(yo_args)

        # If there is a console user, go ahead and trigger the
        # notification immediately for them.
        if get_console_user()[0]:
            touch_watch_path(WATCH_PATH)

    else:
        # Yo has been run by the current user directly
        # Non-root users cannot get the cached notifications, so just
        # run the one provided on the commandline (Do not add a receipt.
        run_yo_with_args(yo_args)


def get_argument_parser():
    """Create yo's argument parser."""
    # This wrapper script adds the --cached and --cleanup args which
    # are meant to be used by the associated LaunchAgents and
    # LaunchDaemons to get their work done.
    description = "Yo launcher arguments:"
    parser = argparse.ArgumentParser(
        description=description,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    phelp = ("Run cached notifications (must be run as console user). This "
             "option is normally run by the LaunchAgent and is not intended "
             "for interactive use.")
    parser.add_argument("--cached", help=phelp, action="store_true")
    phelp = "Remove all cached notifications (must be run as root)."
    parser.add_argument("--cleanup", help=phelp, action="store_true")

    # The parser's epilog is where we put all of the real argument help.
    parser.epilog = YO_HELP

    return parser


def run_yo_with_args(args):
    """Run the yo binary with supplied args using subprocess"""
    args = [YO_BINARY] + args
    call(args)


def process_notifications():
    """Process scheduled notifications for current console user

    Compare list of scheduled notifications against receipts for
    the user, and only deliver if notification has not previously been
    sent.
    """
    cached_args = get_scheduled_notifications()
    receipts = get_receipts()

    for arg_set in cached_args:
        if arg_set not in receipts or \
                cached_args[arg_set] != receipts[arg_set]:
            args = eval(arg_set) # pylint: disable=eval-used
            run_yo_with_args(args)
            add_receipt(args)


def get_scheduled_notifications():
    """Get a dictionary of all scheduled notification arguments"""
    # We _can_ use CopyAppValue here because the preferences have been
    # set for AnyUser.
    notifications = CFPreferencesCopyAppValue("Notifications", BUNDLE_ID)
    return notifications or {}


def schedule_notification(args):
    """Schedule a notification to be delivered to users"""
    # Get the arguments from the system-level preferences (i.e.
    # /Library/Preferences/com.sheagcraig.yo.plist). This precludes us
    # from using the _slightly_ shorter CFPreferencesCopyAppValue.
    notifications = CFPreferencesCopyValue(
        "Notifications", BUNDLE_ID, kCFPreferencesAnyUser,
        kCFPreferencesAnyHost)
    # We get an immutable NSCFDictionary back from CFPreferences, so
    # copy it to a mutable python dict.
    notifications = dict(notifications) if notifications else {}

    # Convert args to string representation of a python list for later
    # reconversion back to python.
    notifications[repr(args)] = NSDate.alloc().init()

    CFPreferencesSetValue(
        "Notifications", notifications, BUNDLE_ID, kCFPreferencesAnyUser,
        kCFPreferencesAnyHost)

    # Use the simpler `AppSynchroniize`; it seems to flush all changes,
    # despite having to use the primitive methods above.
    CFPreferencesAppSynchronize(BUNDLE_ID)


def clear_scheduled_notifications():
    """Clear all scheduled notifications"""
    CFPreferencesSetValue(
        "Notifications", {}, BUNDLE_ID, kCFPreferencesAnyUser,
        kCFPreferencesAnyHost)
    CFPreferencesAppSynchronize(BUNDLE_ID)


def get_receipts():
    """Get the delivery receipts for the current console user"""
    receipts = CFPreferencesCopyValue(
        "DeliveryReceipts", BUNDLE_ID, get_console_user()[0],
        kCFPreferencesAnyHost)
    # Convert result into a mutable python dict.
    return dict(receipts) if receipts else {}


def add_receipt(yo_args):
    """Add a receipt to current user's receipt preferences.

    Args:
        yo_args (list of str): Arguments to yo app as for a subprocess.
    """
    receipts = get_receipts()
    receipts[repr(yo_args)] = NSDate.alloc().init()
    CFPreferencesSetAppValue("DeliveryReceipts", receipts, BUNDLE_ID)
    CFPreferencesAppSynchronize(BUNDLE_ID)


def is_console_user():
    """Test for whether current user is the current console user"""
    console_user = get_console_user()
    return False if not console_user[0] else os.getuid() == console_user[1]


def get_console_user():
    """Get informatino about the console user

    Returns:
        3-Tuple of (str) username, (int) uid, (int) gid
    """
    return SCDynamicStoreCopyConsoleUser(None, None, None)


def touch_watch_path(path):
    """Touch a path to trigger a watching LaunchDaemon, then clean up"""
    with open(path, "w") as ofile:
        ofile.write("Yo!")
    # Give the LaunchDaemon a chance to work before cleaning up.
    time.sleep(5)
    os.remove(path)


def exit_if_not_root():
    """Exit if executing user is not root"""
    if os.getuid() != 0:
        sys.exit("Only the root user may schedule notifications.")


if __name__ == "__main__":
    main()
