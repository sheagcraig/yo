# Yo: Custom User Notifications with Swift

## Overview
![Yo example](https://github.com/sheagcraig/yo/blob/testing/docs/example.png?raw=true)

Yo is a simple app for sending custom, *persistent* native Cocoa notifications to the Notification
Center in macOS 10.10+. It allows customizing all of the various notification text fields and button labels, the sound
effect played, and the application to open when the (optional) action button has been clicked.
Further, it allows you to configure the application icon to be displayed with the notification (with
caveats), and configure some of the launch properties, like whether to "poof" when clicked, and how
to display when the screen is locked.

Included with the Yo app is a launcher utility named `yo_scheduler`. Yo allows you to call it from the
commandline, but only when a user is actively logged into a GUI session (and
generally, by that user). That's where the launcher script steps in. `yo_scheduler`
takes ideas from the [excellent Outset
tool](https://github.com/chilcote/outset) to guarantee that configured
notifications will be delivered to all users on a machine at least once. This
is of critical importance to Mac administrators who need to reliably notify
enterprise users of pending changes or critical information. Yo and `yo_scheduler` are
management tool agnostic, and have been used by Munki and Casper administrators
around the world.

Yo differs from [terminal-notifier](https://github.com/alloy/terminal-notifier) in that it creates
persistent notifications that remain in place until clicked. As such, it allows you to customize
these buttons and their actions. Also, it allows you to customize the application icon displayed.

If you just want a notification, download the current installer package from the
[releases](https://github.com/sheagcraig/yo/releases) page.

You can customize the icon used in the notifications by providing the `-i` argument. However, if you
want to permanently customize the icon/app name/etc, you can modify the XCode project and build it
yourself. Instructions are provided below.

Finally, thanks to @jatoben for the gracious sharing of his Swift
[CommandLine](https://github.com/jatoben/CommandLine) library/Framework on GitHub.

## Build & Installation
You only need to follow these instructions if you want to build the app
yourself. Obviously, you'll need a recent XCode.

1. Git clone or download the project.
2. Open the project in XCode and set the App Icon to your desired icon. Please read the Icon section below for more info on what is going on here. To change the icon provided with yo, open the project in XCode and navigate to the Images.xcassets file in the file browser. Simply drag a 128x128px replacement png over the one already in place. Optionally, if you want *more* icon sizes, feel free to go nuts and fill them all in.
3. Build. (CMD-B)
4. Copy the built app (Contextual-click on the Products->yo.app->Show in Finder) wherever you see fit, although `/Applications/Utilities` seems like a suitable place. Alternately, you can use the Product->Archive menu option to export a copy of the app or build an installer package (if you have a developer ID).

Note: If you Run/(CMD-R) from XCode, it will just report back usage with a command line parsing error. Just ignore that and run from the command line.

## Package build and deployment
The `pkg` folder includes a Makefile for use with [the luggage](https://github.com/unixorn/luggage) that builds a package installer, should you need to build one yourself. The Makefile configures the package to install the `yo.app` bundle in `/Applications/Utilities`, and the scheduler script at `/usr/local/bin/yo_scheduler`. Feel free to customize these as you see fit.

## Usage
The yo installer package adds a command line script to `/usr/local/bin/yo_scheduler` which is the preferred method for calling yo. If you are building the app with custom icons, feel free to copy this script wherever is convenient, although `/usr/local/bin/` is in the default `PATH`.

Due to its install location being in the default PATH, you can then call yo by simply typing `yo_scheduler -t "This is amazing"`, for example. (`yo_scheduler -h` will give you full usage information).

The `yo_scheduler` script creates a "scheduled notification". Through a system of LaunchAgents and LaunchDaemons, yo will ensure that each user gets the notification delivered to them at the soonest possible opportunity. Active console users will get the notification immediately. Other users will get the notification when they next log in.

### Note:
The yo app by itself, if opened via double-clicking the app, running from Spotlight/Launchpad, etc, does nothing. It must be called with arguments, and the actual binary `yo.app/Contents/MacOS/yo` is what is executable. However, this only works if a user is currently logged in.

If you are experiencing weird hanging or no notifications being sent, check to make sure yo isn't already running. For automated messaging via a management system's triggers, it is recommended that you stick to using the scheduler script as per above. If you just really don't want to use the scheduler, make sure that your tooling is running Yo in the right user context. Which logged in user is the notification _for_? Get their UID and then run yo by running launchctl: `launchctl asuser <UID> /path/to/yo.app/Contents/MacOS/yo <arguments>`. But really, use the scheduler because it solves all of these problems and more.

### Arguments:
Yo, as called through the `yo_scheduler`, has the following arguments. The only required argument is the `-t`/`--title` argument. Normally, admins should schedule notifications using the root user, either as a scripted action through their management framework, or using the `sudo` utility to elevate privileges. For testing purposes, you can run a notification once for the current user by executing the `yo_scheduler` as that user. No notifications will be stored for delivery.

Test all notifications prior to delivery, as the maximum line-length of characters differs for the title, subtitle, and info fields, which in turn can be compressed even shorter when the length of the action or cancel buttons grows beyond 8 characters.

This notification demonstrates the available content areas. Not all of these are required!
![Yo example](https://github.com/sheagcraig/yo/blob/testing/docs/NotificationAreas.png?raw=true)

#### Notification Body Content Arguments
The following arguments control the body text for the notification. When the buttons fit in their normal sizes, they have the below mentioned maximum character legnths. However, the layout of the notification is elastic to allow longer button text at the expense of body text.
* `-t`, `--title`[title text] *Required*: The main title for the notification. The title is topmost in the notification, with the heaviest fontface, and has a limited length of 34 characters, after which an ellipsis (e.g. '...') is shown.
* `-s`, `--subtitle` [subtitle text]: Subtitle for the notification. The subtitle is displayed below the title and above the "info" in a lighter, smaller font than the title, and has a maximum length of 37 characters.
* `-n`, `--info` [info text]: Further information for the notification. The info field is displayed below both the title and the subtitle, in a lighter, smaller font than the subtitle, and has a maximum length of 38 characters.
* `-i`, `--icon` [path]: The icon argument allows you to add an icon to the notification's leftmost area (this does not replace the main icon). This must be a complete path. PNG and JPG files work. Other image types may work, although it has not been tested. To permanently replace the main icon, you can build Yo with your own image assets (see the above section on building Yo). This is the mechanism by which iTunes displays the album art for "Now Playing" notifications. Please note, use of this argument will further reduce the space available for text to display.
* `-c`, `--content-image` [path]: The content-image argument allows you to specify the path to an image to be used for the additional image spot at the right side of the notification, provided through Notification Center's private API. This is how NotificationCenter displays images sent as iMessages via the Messages app. Please note, use of this argument will further reduce the space available for text to display.
* `-z`, `--delivery-sound` [Sound name]: This argument allows you to specify the _name_ of the sound to play when
  delivering the notification. (Defaults to the system's default notification sound).
  If you want to use a different sound, you must provide the *name* of the sound to the -z argument, not the filename, and not the path. I.e "Sosumi", not "Sosumi.aiff" or "/System/Library/Sosumi.aiff".
  
  The sound will be found by successively searching through each of the following paths until the sound is found:
  - `~/Library/Sounds`
  - `/Library/Sounds`
  - `/Network/Library/Sounds`
  - `/System/Library/Sounds` (This is where all of the builtin sounds live)

  If you want to include a custom sound, it needs to be available in one of those paths. So for example, if you wanted to use the sound file "TotalEclipseOfTheHeart.aiff", copy it to `/Library/Sounds` (which may not exist by default), and use the delivery sound option like this:
  `yo_scheduler.app -t "Some title" -z "TotalEclipseOfTheHeart"`
  
  Sounds must have an `aiff` extension `.aif` is not valid.

#### Notification Button Arguments
By default, with no button arguments, notifications have a single button, labeled `Close`, which dismisses the otherwise persistent notification. The following arguments allow you to configure the "action" button text, and what it does when clicked, and to customize the cancel button's text.
* `-b`, `--action-btn` [text]: Include an action button, with the button label text
supplied to this argument. The maximum length of this button is 25 characters, although using more than 8 characters will result in the main notification text decreasing in maximum size to accomodate the button.
* `-o`, `--other-btn` [text]: Specify the "Cancel" button label text. This button is always visible, and if not specified, defaults to `Close`. The maximum length of this button is 25 characters, although using more than 8 characters will result in the main notification text decreasing in maximum size to accomodate the button.
* `-a`, `--action-path` [path]: This option allows you to specify what happens
when the action button is pressed. Acceptable arguments are the path to an
application to open, a URL to be opened in the default web browser, a path to a file to open in its default handler (e.g. PDF in Preview, etc), or any other file type that has a handler. Behind the scenes, Yo
will run the `open` command with this value as its argument, so anything that
works as an argument to `open` will behave here exactly as for that utility.
For example, `--action-path /Applications/Managed Software Center.app` will
open the Munki Managed Software Center when the button is clicked. `--action-path http://sheagcraig.com` will open that website when the action button is clicked. For applications, provide the
full path to the _bundle_ as the argument (the folder that ends in the `.app`
extension, not the executable binary contained within). This option only does
something if `-b`/`--action-btn` is also specified. The default value is to do
nothing.
* `-B`, `--bash-action` [bash script]: The `--bash-action` argument allows you to
specify any number of Bash command line actions to run when the action button
is clicked. Provide the script as the argument to this flag, making sure to
properly escape all reserved characters (`!`, `'`, and `"` are the most common
offenders), delimit individual lines with a semicolon or the `&&` or `||`
operators, and wrap the entire script in either `"` or `'`.  This option only
does something if -b/--action-btn is also specified. Example: `--bash-action
'touch /Users/Shared/somefile.txt; say "These are not the droids you are
looking for". The default value is to do nothing.

#### Delivery Arguments
* `-d`, `--ignores-do-not-disturb`: This argument directs NotificationCenter to make your notification appear even if
the computer is in do-not-disturb mode.
* `-l`, `--lockscreen-only`: This argument directs NotificationCenter to make your notification appear only if
the computer is locked. If set, no buttons will be available, so the button arguments will be ignored.
* `-p`, `--poofs-on-cancel`: Set to make your notification 'poof' when the cancel
button is hit.
* `-m`, `--banner-mode`: This argument currently does not work! Set if you would like to send a
non-persistent notification. Non-persistent notifications may not have buttons, so all button arguments will be ignored.
* `--cleanup`:   Remove all scheduled notifications (must be run as root) Ignores all other arguments.
* `--cached`: Process cached notifications and ignore all other arguments (must be run as console user). This option
is normally run by the LaunchAgent and is not intended for interactive use.

#### Other Arguments
* `-v`, `--version`: Print version information and quit.
* `-h`, `--help`: Print help and usage information and quit.

## Emoji
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
$ yo_scheduler -t $(echo -ne '\xf0\x9f\x92\xa9')
```
= Smiling poo emoji notification.

You can also do `printf '\xf0\x9f\x92\xa9'`.

## Examples
```
# Example of basic notification:
yo_scheduler -t "Taco Time"

# Example with lots of text:
yo_scheduler -t "Taco Time" -s "Chorizo is best." -n "Although I also enjoy al pastor of course."

# Example with emoji and tons of escaped characters:
yo_scheduler -t "$(printf "\xf0\x9f\x92\xa9\n") says, \"Let's dance$(printf \!)\""

# Example with action button, opening a webpage in your default browser:
yo_scheduler -t "Taco Time" -b "Yum" -a "http://en.wikipedia.org/wiki/Taco"

# Example opening an app:
yo_scheduler -t "Taco Time" -b "Yum" -a "/Applications/TacoParty.app"

# Example-What if you want a one-button persistent notification that doesn't *do* anything?
yo_scheduler -t "Taco Time" -o "Accept"

# Example-alternate icon using the -i argument
yo_scheduler -t "Taco Time" -i "/Users/blanconino/Pictures/taco.png"

# Example-custom sound and bash script with escaped characters.
yo_scheduler -t "Taco Time" -z "Taco" -b "Eat" -B "say 'I hope you enjoyed your tacos\!'"
```

## Application Icon, Caveats, and Nerdery
### Icons
Most organizations will probably want yo to display a custom icon in the notification. There are a couple of different ways notifications determine what to use for the icon:
1. By default, a notification uses the icon for the application sending the notification.
2. Using a private API, an application can specify an image file to use for the icon.

yo uses option 2 if you use the `--icon` option. However, since this is a private mechanism used by Apple to show album art in iTunes notifications, the application icon will *still* show up, just smaller, and to the side of the primary icon.

So if you really just want to use *your* icon, you need to build the project in XCode yourself. And even so, there are some issues about getting it to "know" that you've changed the icon.

Notification Center is picky about the icon it displays for your notification. If a notification has been sent previously, a subsequent icon change will not be detected or updated by Notification Center, as the original one has been cached.

Therefore, it is easiest to apply the icon you want before sending any notifications for the first time to avoid any hassles. If you get stuck with the wrong icon, you should be able to change the project Bundle Identifier in the project->General pane; or you can increment the build number in the same place. Arguably, you would want to change the Bundle Identifier to match your organization anyway.

See [here](http://stackoverflow.com/questions/11856766/osx-notification-center-icon) for more info.

### The other nerdery
Normally, for a notification to be persistent (meaning, it stays onscreen until a button is clicked on the notification), the notification needs to be an "alert" style notification. To do this, yo sets the Info.plist key "NSUserNotificationAlertStyle" with value "alert". However, Apple does not allow just anyone to make "alerts". To use an alert in your app, the app has to be signed with a developer ID.

Or does it... There's another private API key that allows you to show buttons on a "banner", which is the default type, and available for unsigned apps. So that's what yo uses.

Of course, your results may vary. If you can't get the "alert" style notification to appear, try signing the project with your Developer ID and rebuilding.

The scheduler stores notifications to be delivered in the CFPreferences system. The scheduled notifications are (eventually) stored in `/Library/Preferences/com.sheagcraig.yo.plist`, and the delivery receipts are stored in `~/Library/Preferences/com.sheagcraig.yo.plist`. To grow future scheduling options, the structure of these preferences will probably change, so do not rely on the current structure.

### What's next?
The next step in Yo's development will be to get it ready for Swift 4 and macOS 10.13, and to add to the scheduling arguments provided by the `yo_scheduler` app. 

* Specify a date after which scheduled notifications will no longer be delivered (for users who haven't already gotten them). 
* Allow notifications to be delivered up to `x` number of times rather than just once.
* Add a blacklist of users to whom notifications should not be delivered.
* Add a delivery delay property to the scheduler. Notifications are delivered immediately to the current user, and as soon as possible after login for users not active at the time the notification is scheduled. This would allow it to be delayed slightly longer.
