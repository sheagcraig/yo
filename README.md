# yo

## Custom User Notifications with Swift

### Overview
`yo` is a simple app for sending custom, *persistent* notifications to the Notification Center in OS X Yosemite and Mavericks. It allows customizing the various text fields and button labels, as well as the application to open when the (optional) action button has been clicked. Further, it allows you to configure the application icon to be displayed with the notification, although there are some caveats to this as detailed below. Also, admins using the Casper Suite should make sure to read the Casper section below.

It differs from [terminal-notifier](https://github.com/alloy/terminal-notifier) in that it creates persistent notifications that remain in place until clicked. As such, it allows you to customize these buttons and their actions. Also, it allows you to customize the application icon displayed (kind of... again, see below).

If you just want a notification, download the current installer package from the [releases](https://github.com/sheagcraig/yo/releases) page. Please note, the installer package does not include the Casper scripts.

If you want to customize the icon/app name/etc, you will need to modify the XCode project and build it yourself. Instructions are provided below.

Finally, thanks to @jatoben for the gracious sharing of his Swift [CommandLine](https://github.com/jatoben/CommandLine) library/Framework on GitHub.

### Build & Installation
You only need to follow these instructions if you want to build the app yourself. Obviously, you'll need a recent XCode.

1. Clone the project.
2. Open the project in XCode and set the App Icon to your desired icon. Please read the Icon section below for more info on what is going on here. To change the icon provided with yo, open the project in XCode and navigate to the Images.xcassets file in the file browser. Simply drag a 128x128px replacement png over the one already in place. Optionally, if you want *more* icon sizes, feel free to go nuts and fill them all in.
3. Build. (CMD-B)
4. Copy the built app (Contextual-click on the Products->yo.app->Show in Finder) wherever you see fit, although `/Applications/Utilities` seems like a suitable place. Alternately, you can use the Product->Archive menu option to export a copy of the app or build an installer package (if you have a developer ID).

Note: If you Run/(CMD-R) from XCode, it will just report back usage with a command line parsing error. Just ignore that and run from the command line.

### Usage
The yo installer package adds a command line script to `/usr/local/bin/yo` which is the preferred method for calling yo. If you are building the app with custom icons, feel free to copy this script wherever is convenient, although `/usr/local/bin/` is in the default `PATH`.

Due to its install location being in the default PATH, you can then call yo by simply typing `yo -t "This is amazing"`, for example. (`yo -h` will give you full usage information).

The yo script will test for a console user prior to execution and bail if nobody is logged in. If there is no console user, there is no notification center, and yo can't do anything. Therefore, this script ensures it only runs when possible to succeed.

#### Note:
The yo app by itself, if opened via double-clicking the app, running from Spotlight/Launchpad, etc, does nothing. It must be called with arguments, and the actual binary `yo.app/Contents/MacOS/yo` is what is executable. However, this only works if a user is currently logged in.

If you are experiencing weird hanging or no notifications being sent, check to make sure yo isn't already running. For automated messaging via a management system's triggers, it is recommended that you stick to using the script as per above. If you really want to run it "raw": from the actual binary inside (not from running or calling the "yo.app") the full path to call yo is `/Applications/Utilities/yo.app/Contents/MacOS/yo`.

#### Arguments:
```
Usage: /Users/shcrai/Library/Developer/Xcode/DerivedData/yo-dmleuiivjmidrrfzyhbmtcwsvqkm/Build/Products/Debug/yo.app/Contents/MacOS/yo [options]
  -t, --title:
      Title for notification. REQUIRED.
  -s, --subtitle:
      Subtitle for notification.
  -n, --info:
      Informative text.
  -b, --action-btn:
      Include an action button, with the button label text supplied to this argument.
  -a, --action-path:
      Application to open if user selects the action button. Provide the full path as the argument. This option only does something if -b/--action-btn is also specified.
  -B, --bash-action:
      Bash script to run. Be sure to properly escape all reserved characters. This option only does something if -b/--action-btn is also specified. Defaults to opening nothing.
  -o, --other-btn:
      Alternate label for cancel button text.
  -i, --icon:
      Complete path to an alternate icon to use for the notification.
  -c, --content-image:
      Path to an image to use for the notification's 'contentImage' property.
  -z, --delivery-sound:
      The name of the sound to play when delivering or 'None'. The name must not include the extension, nor any path components, and should be located in '/Library/Sounds' or '~/Library/Sounds'. (Defaults to the system's default notification sound). See the README for more info.
  -d, --ignores-do-not-disturb:
      Set to make your notification appear even if computer is in do-not-disturb mode.
  -l, --lockscreen-only:
      Set to make your notification appear only if computer is locked. If set, no buttons will be available.
  -p, --poofs-on-cancel:
      Set to make your notification 'poof' when the cancel button is hit.
  -m, --banner-mode:
      Does not work! Set if you would like to send a non-persistent notification. No buttons will be available if set.
  -v, --version:
      Display Yo version information.
  -h, --help:
      Show help.
```

Notes:
- Title is mandatory. All other arguments are optional.
- `-m/--banner-mode` does not seem to work at this time.
- The `-a/--action` argument needs a path or URL. yo just calls `open`, so anything that would work there, should work here.
- If a "cancel" button doesn't make sense for your needs, but you don't want two buttons on your notification, just use `-o/--other-btn` with a label that seems appropriate, like "Accept", or perhaps "Confirm", but no `-b/--btext`.
- Remember, this is (probably) a Bash shell. If you don't escape reserved characters like `!` you may get unexpected results. (`!` is the Bash history expansion operator!)

### Sound
If you want to use a different sound, you must provide the *name* of the sound to the -z argument, not the filename, and not the path. I.e "Sosumi", not "Sosumi.aiff" or "/System/Library/Sosumi.aiff".

The search path is:
- ~/Library/Sounds
- /Library/Sounds
- /Network/Library/Sounds
- /System/Library/Sounds (This is where all of the builtin sounds live)

If you want to include a custom sound, it needs to be available in one of those paths. So for example, if you wanted to use the sound file "TotalEclipseOfTheHeart.aiff", copy it to `/Library/Sounds` (which may not exist by default), and use the delivery sound option like this:
`yo.ap -t "Some title" -z "TotalEclipseOfTheHeart"`

Sounds must be a aiff; extension .aif is not valid.

### Emoji
Emoji characters are allowed, although getting them into a bash command line context is tricky.

You can drag an emoji from the Special Characters palette. That's the easiest way.

Otherwise, if you need the hex code, find it in the Special Characters and go to bash:
```
echo -ne '<drag the emoji here>' | hexdump
```
This will print out the hex code for the emoji. It's the rightmost column of values that are in hex. You have to slap a \x before each two-characters, and then you can echo it back up as a command substitution...

Complete process:
```
$ echo -ne '💩' | hexdump
0000000 f0 9f 92 a9                                    
0000004

# So 'f09f92a9' is the hex value...
$ /Applications/Utilities/yo.app/Contents/MacOS/yo -t $(echo -ne '\xf0\x9f\x92\xa9')
```
= Smiling poo emoji notification.

You can also do `printf '\xf0\x9f\x92\xa9'`.

### Examples
```
# Example of basic notification:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time"

# Example with lots of text:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -s "Chorizo is best." -n "Although I also enjoy al pastor of course."

# Example with emoji and tons of escaped characters:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "$(printf "\xf0\x9f\x92\xa9\n") says, \"Let's dance$(printf \!)\""

# Example with action button, opening a webpage in your default browser:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -b "Yum" -a "http://en.wikipedia.org/wiki/Taco"

# Example opening an app:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -b "Yum" -a "/Applications/TacoParty.app"

# Example-What if you want a one-button persistent notification that doesn't *do* anything?
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -o "Accept"

# Example-alternate icon using the -i argument
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -i "/Users/blanconino/Pictures/taco.png"

# Example-custom sound and bash script with escaped characters.
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -z "Taco" -b "Eat" -B "say 'I hope you enjoyed your tacos\!'"
```

### Casper Usage
#### Overview
yo provides a script, yo-casper.py which you can upload to your JSS for posting
notifications. This script is the safest way to ensure your notifications post,
and do so without jacking up the computer. Like the yo script installed in
/usr/local/bin, yo-casper only runs if a GUI user is logged in.

#### Why Bother?
Running yo with the Policy/Files & Processes/Execute Command function
of Casper results in scoped client machines becoming unable to
check-in or run further policies. This is due to something broken in
Casper's Execute Command function that prevents yo from ever
completing. Furthermore, using `"` instead of `'` for quoting causes strange
things to happen to the arguments. Therefore, do not use Execute Command.

#### Where are the Casper Scripts?
The folder containing yo-casper.py and the extension attribute to work with it are not included in the installer package, since managed client machines will not need these components. You can get them from the GitHub page by cloning the project or downloading as a zip, expanding, and then looking in the `casper` folder. Or you can just cut and paste from GitHub directly into the Scripts and Extension Attributes sections of your JSS.

#### Using yo-casper
yo-casper.py hardcodes the following arguments to yo in the 4th-11th
parameter fields for Casper scripts. As such, you should rename them
in Casper Admin to match:

4. Title
5. Subtitle
6. Info
7. Action Button
8. Action Path
9. Bash Action
10. Other Button
11. Icon

![Casper Admin Settings for yo-casper.py](https://raw.githubusercontent.com/sheagcraig/yo/master/casper/casper-script-setup.png)

Any policy posting a notification with yo should probably have the
frequency of "Ongoing" coupled with being scoped to a smart group if you want
to ensure that the notification is posted.

If a computer checks in and no console user is available, yo will not post a
notification (because it can't!). You probably are posting a notification
because you want the user to see it, thus, a frequency of ongoing keeps trying.

However, now your users are getting a notification every check-in-period, which
quickly deadens their soul and leads to ignoring your messages. To avoid this,
there are a couple of options:
1. Scope to a smart group that needs the notification, and add in some method
   for the computer to drop out of the group after it has received the
   notification, or performed the action you notified them about in the first
   place. For example, a notification to remove adware should no longer be
   offered once the computer has the adware removed (via a removal policy, with
   a followup-recon.

   Second example: You notify users about an impending OS update. Once
   they have received the update, they fall out of the group the notification
   is scoped to.
2. Use an extension attribute to determine whether a notification has been
   delivered. The yo-casper.py script logs to a file at /var/log/yo-casper.log.
   This log file includes the date stamp, arguments, and an md5 hash generated
   from the supplied arguments that will be consistent across all executions of
   that notification. Included in the `casper` folder is an extension attribute
   that can be used to determine whether a particular notification has been
   received.

   Add this EA to your JSS, and edit the `SEARCH_HASH` variable to use the hash
   for the notification you wish to send. You can run yo-casper.py on your own
   computer to quickly generate the hash exactly as the Policy/Scripts
   execution will.

   Then, create a smart group with criteria of that EA's value returning
   "False" and Computer Group is whatever group(s) you're interested in scoping
   the notification to.

   Finally, create your Policy with Scripts action, enter the arguments, and
   scope to the smart group created above.

   This is a lot of moving pieces. Sorry. Being awesome isn't easy.

![Extension Attribute](https://raw.githubusercontent.com/sheagcraig/yo/master/casper/OSUpdateNotificationSent.png)
![Extension Attribute](https://raw.githubusercontent.com/sheagcraig/yo/master/casper/OSUpdateNotificationSent2.png)
![Smart Group Criteria](https://raw.githubusercontent.com/sheagcraig/yo/master/casper/Edit_Smart_Computer_Group.png)

#### Recovering from Execute Command
Affected computers can be fixed by removing the broken Execute Command
policy from scope and running `killall jamf`.

#### But Some of the Args Are Missing?
Casper only allows 8 custom arguments, so if you would prefer other arguments
as options, feel free to edit the script to use the correct argument flags.

### Application Icon, Caveats, and Nerdery
#### Icons
Most organizations will probably want yo to display a custom icon in the notification. There are a couple of different ways notifications determine what to use for the icon:
1. By default, a notification uses the icon for the application sending the notification.
2. Using a private API, an application can specify an image file to use for the icon.

yo uses option 2 if you use the `--icon` option. However, since this is a private mechanism used by Apple to show album art in iTunes notifications, the application icon will *still* show up, just smaller, and to the side of the primary icon.

So if you really just want to use *your* icon, you need to build the project in XCode yourself. And even so, there are some issues about getting it to "know" that you've changed the icon.

Notification Center is picky about the icon it displays for your notification. If a notification has been sent previously, a subsequent icon change will not be detected or updated by Notification Center, as the original one has been cached.

Therefore, it is easiest to apply the icon you want before sending any notifications for the first time to avoid any hassles. If you get stuck with the wrong icon, you should be able to change the project Bundle Identifier in the project->General pane; or you can increment the build number in the same place. Arguably, you would want to change the Bundle Identifier to match your organization anyway.

See [here](http://stackoverflow.com/questions/11856766/osx-notification-center-icon) for more info.

#### The other nerdery
Normally, for a notification to be persistent (meaning, it stays onscreen until a button is clicked on the notification), the notification needs to be an "alert" style notification. To do this, yo sets the Info.plist key "NSUserNotificationAlertStyle" with value "alert". However, Apple does not allow just anyone to make "alerts". To use an alert in your app, the app has to be signed with a developer ID.

Or does it... There's another private API key that allows you to show buttons on a "banner", which is the default type, and available for unsigned apps. So that's what yo uses.

Of course, your results may vary. If you can't get the "alert" style notification to appear, try signing the project with your Developer ID and rebuilding.
