#!/usr/bin/python


"""yo-casper extension attribute template

Since you can't give input to extension attributes, you need to enter
the md5 hash of the notification you want to test for having
successfully been delivered here.

To generate the md5 hash, run a copy of yo-casper.py with the desired
arguments. The hash is the final, 32 character, element of the printed
output.

Replace the value of the variable SEARCH_HASH with the one generated as per
below, making sure to leave the string wrapped with " characters.

For more information, see the yo README.
"""


import os


# Change me!
SEARCH_HASH = "f685353b7538e0c889bb6fd36974e22d"

YO_CASPER_LOG = "/var/log/yo-casper.log"


def main():
    """Look for a yo-casper log with hash entry SEARCH_HASH."""
    result = "False"
    if os.path.exists(YO_CASPER_LOG):
        with open(YO_CASPER_LOG, "r") as logfile:
            logtext = logfile.read()

        for line in logtext.splitlines():
            if (len(line.split(",")) == 3 and
                    SEARCH_HASH == line.split(",")[2].strip()):
                result = "True"
                break

    print "<result>%s</result>" % result


if __name__ == "__main__":
    main()
