#!/usr/bin/python


import argparse
import os
from subprocess import call
import sys
import time

from Foundation import (
    CFPreferencesAppSynchronize, CFPreferencesCopyAppValue,
    CFPreferencesSetValue, kCFPreferencesAnyUser, kCFPreferencesCurrentHost)
from SystemConfiguration import SCDynamicStoreCopyConsoleUser


__version__ = "2.0.0"
BUNDLE_ID = "com.sheagcraig.yo"
CLEANUP_PATH = "/private/tmp/.com.sheagcraig.yo.cleanup.launchd"
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
    """Manage Yo notifications"""
    # Capture commandline args.
    parser = get_argument_parser()
    # Use the parse_known_args method to automatically separate out the
    # yo_scheduler (this script) args from the yo app's args.
    launcher_args, yo_args = parser.parse_known_args()

    if any(flag in yo_args for flag in ("--version", "-v")):
        # Skip further checks if version is requested.
        args = ["yo.py"] + yo_args
        run_yo_with_args(args)

    elif launcher_args.cached:
        # Yo is being run by a LaunchAgent for the current console user.
        cached_args = get_cached_args()
        all_args = cached_args + [yo_args]

        # Post all of the stored notifications!
        for arg_set in all_args:
            run_yo_with_args(arg_set)

        # Trigger the LaunchDaemon to clean up.
        with open(CLEANUP_PATH, "w") as ofile:
            ofile.write("Yo!")

    elif launcher_args.cleanup:
        # Yo is being called by the cleanup LaunchDaemon.
        clear_scheduled_notifications()
        time.sleep(5)
        os.remove(CLEANUP_PATH)

    elif not is_console_user():
        if os.getuid() != 0:
            sys.exit("Only the root user may cache notifications for "
                     "other users.")
        # Only the current console user can trigger a notification.
        # So we will cache the required arguments and try to trigger
        # an on_demand notification. If there is no console user, the
        # notification will trigger on the next login.
        cache_args(yo_args)

        if get_console_user()[0]:
            with open(WATCH_PATH, "w") as ofile:
                ofile.write("Yo!")

            time.sleep(5)
            os.remove(WATCH_PATH)

    else:
        # Yo has been run by the current user directly
        # Non-root users cannot get the cached notifications, so just
        # run the one provided on the commandline.
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
             "option is normally run by the LaunchAgent.")
    parser.add_argument("--cached", help=argparse.SUPPRESS,
                        action="store_true")
    phelp = "Clean up cached notifications (must run as root)."
    parser.add_argument("--cleanup", help=argparse.SUPPRESS,
                        action="store_true")

    # The parser's epilog is where we put all of the real argument help.
    parser.epilog = YO_HELP

    return parser


def run_yo_with_args(args):
    args = [YO_BINARY] + args
    call(args)


def is_console_user():
    console_user = get_console_user()
    return False if not console_user[0] else os.getuid() == console_user[1]


def get_console_user():
    return SCDynamicStoreCopyConsoleUser(None, None, None)


def get_cached_args():
    notifications = CFPreferencesCopyAppValue("Notifications", BUNDLE_ID)
    return notifications or []


def cache_args(args):
    notifications = CFPreferencesCopyAppValue("Notifications", BUNDLE_ID)
    if not notifications:
        notifications = []

    notifications = notifications + [args]

    CFPreferencesSetValue(
        "Notifications", notifications, BUNDLE_ID, kCFPreferencesAnyUser,
        kCFPreferencesCurrentHost)
    CFPreferencesAppSynchronize(BUNDLE_ID)


def clear_scheduled_notifications():
    CFPreferencesSetValue(
        "Notifications", [], BUNDLE_ID, kCFPreferencesAnyUser,
        kCFPreferencesCurrentHost)
    CFPreferencesAppSynchronize(BUNDLE_ID)


if __name__ == "__main__":
    main()
