#!/usr/bin/python

"""yo-casper
This script allows you to use the Policy/Scripts function of Casper to
post yo notification safely.

Running yo with the Policy/Files & Processes/Execute Command function
of Casper results in scoped client machines becoming unable to
check-in or run further policies. This is due to something broken in
Casper's Execute Command function that prevents yo from ever
completing.

Affected computers can be fixed by removing the broken Execute Command
policy from scope and running killall jamf.

Upload this script to your JSS to use.

This script hardcodes the following arguments to yo in the 4th-11th
parameter fields for Casper scripts. As such, you should rename them
in Casper Admin to match:

4 = Title
5 = Subtitle
6 = Info
7 = Action Button
8 = Action Path
9 = Bash Action
10 = Other Button
11 = Icon

If you would prefer other arguments as options, feel free to edit the
tuples below to use the correct argument flag.
"""


import datetime
import hashlib
import os
import subprocess
import sys


YO_CASPER_LOG = "/var/log/yo_casper.log"


# See if there is a user; You cannot post a notification if there isn't.
output = subprocess.check_output(["who"])

# Look for users with the term-type console (to avoid users named
# console)
if [line for line in output.splitlines() if line.split()[1] == "console"]:
    # Get the arguments.
    # Dump the first three Casper-reserved args of mount point, computer
    # name, and username as well as the script name.
    args = sys.argv[4:]

    title = ("--title", args[0])
    subtitle = ("--subtitle", args[1])
    info = ("--info", args[2])
    action_button = ("--action-btn", args[3])
    action_path = ("--action-path", args[4])
    bash_action = ("--bash_action", args[5])
    other_button= ("--other-btn", args[6])
    icon = ("--icon", args[7])

    constructed_args = [element for arg in [title, subtitle, info,
                                            action_button, action_path,
                                            bash_action, other_button,
                                            icon] for element in arg if arg[1]]
    constructed_args.insert(
        0, "/Applications/Utilities/yo.app/Contents/MacOS/yo")
    subprocess.call(constructed_args)

    # Log for EA detection of delivery.
    uuid = hashlib.md5(" ".join(constructed_args)).hexdigest()
    if os.path.exists(YO_CASPER_LOG):
        with open(YO_CASPER_LOG, "r") as logfile:
            logtext = logfile.read()
    else:
        logtext = ""
    datestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    logtext += "%s {%s} %s\n" % (datestamp, " ".join(constructed_args), uuid)

    with open(YO_CASPER_LOG, "w") as logfile:
        logfile.write(logtext)