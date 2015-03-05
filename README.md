# yo

## Custom User Notifications with Swift

### Overview
```yo``` is a simple app for sending custom, *persistent* notifications to the Notification Center in OS X Yosemite and Mavericks. It allows customizing the various text fields and button labels, as well as the application to open when the (optional) action button has been clicked. Further, it allows you to configure the application icon to be displayed with the notification, although there are some caveats to this as detailed below.

It differs from [terminal-notifier](https://github.com/alloy/terminal-notifier) in that it creates persistent notifications that remain in place until clicked. As such, it allows you to customize these buttons and their actions. Also, it allows you to customize the application icon displayed (kind of... again, see below).

If you just want a notification, download the current installer package from the [releases](https://github.com/sheagcraig/yo/releases) page.

If you want to customize the icon/app name/etc, you will need to modify the XCode project and build it yourself. Instructions are provided below.

Finally, thanks to @jatoben for the gracious sharing of his Swift [CommandLine](https://github.com/jatoben/CommandLine) library/Framework on GitHub.

### Build & Installation
You only need to follow these instructions if you want to build the app yourself. Obviously, you'll need a recent XCode.

1. Clone the project.
2. Open the project in XCode and set the App Icon to your desired icon. Please read the Icon section below for more info on what is going on here. To change the icon provided with yo, open the project in XCode and navigate to the Images.xcassets file in the file browser. Simply drag a 128x128px replacement png over the one already in place. Optionally, if you want *more* icon sizes, feel free to go nuts and fill them all in.
3. Build. (CMD-B)
4. Copy the built app (Contextual-click on the Products->yo.app->Show in Finder) wherever you see fit, although ```/Applications/Utilities``` seems like a suitable place. Alternately, you can use the Product->Archive menu option to export a copy of the app or build an installer package (if you have a developer ID).

Note: If you Run/(CMD-R) from XCode, it will just report back usage with a commandline parsing error. Just ignore that and run from the commandline.

### Usage
You must call the app from the commandline, from the actual binary inside. Feel free to alias or ln to this file to avoid the long filename in the future.

```
Usage: /Users/scraig/Library/Developer/Xcode/DerivedData/yo-fdmllzzfcwyljsbbpwhduzpfxeqe/Build/Products/Debug/yo.app/Contents/MacOS/yo [options]
-m, --banner-mode:           
Does not work! Set if you would like to send a non-persistent notification. No buttons will be available if set.
-t, --title:                 
Title for notification
-d, --ignores-do-not-disturb:
Set to make your notification appear even if computer is in do-not-disturb mode.
-l, --lockscreen-only:       
Set to make your notification appear only if computer is locked. If set, no buttons will be available.
-s, --subtitle:              
Subtitle for notification
-n, --info:                  
Informative text.
-b, --action-btn:            
Include an action button, with the button label text supplied to this argument.
-o, --other-btn:             
Alternate label for cancel button text.
-p, --poofs-on-cancel:       
Set to make your notification 'poof' when the cancel button is hit.
-i, --icon:                  
Complete path to an alternate icon to use for the notification.
-c, --content-image:         
Path to an image to use for the notification's 'contentImage' property.
-a, --action-path:           
Application to open if user selects the action button. Provide the full path as the argument. This option only does something if -b/--action-btn is also specified. Defaults to opening nothing.
-z, --delivery-sound:        
The name of the sound to play when delivering. Usually this is the filename of a system sound minus the extension. See the README for more info.
-h, --help:                  
Show help.
```

Notes:
- Title is mandatory. All other arguments are optional.
- -m/--banner-mode does not seem to work at this time.
- The action argument needs a path or URL. yo just calls ```open```, so anything that would work there, should work here.
- If a "cancel" button doesn't make sense for your needs, but you don't want two buttons on your notification, just use ```-o/--obtext``` with a label that seems appropriate, like "Accept", or perhaps "Confirm", but no ```-b/--btext```.
- Sounds! If you want to use a different sound, you must provide the name of the sound to the -z argument, not the filename. I.e. "Sosumi". The search path is:
    - ~/Library/Sounds
    - /Library/Sounds
    - /Network/Library/Sounds
    - /System/Library/Sounds

### Examples
```
# Example of basic notification:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time"

# Example with lots of text:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -s "Chorizo is best." -n "Although I also enjoy al pastor of course."

# Example with action button, opening a webpage in your default browser:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -b "Yum" -a "http://en.wikipedia.org/wiki/Taco"

# Example opening an app: 
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -b "Yum" -a "/Applications/TacoParty.app"

# Example-What if you want a one-button persistent notification that doesn't *do* anything?
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -o "Accept"

# Example-alternate icon using the -i argument
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -i "/Users/blanconino/Pictures/taco.png"

```

### Application Icon, Caveats, and Nerdery
#### Icons
Most organizations will probably want yo to display a custom icon in the notification. There are a couple of different ways notifications determine what to use for the icon:
1. By default, a notification uses the icon for the application sending the notification.
2. Using a private API, an application can specify an image file to use for the icon.

yo uses option 2 if you use the --icon option. However, since this is a private mechanism used by Apple to show album art in iTunes notifications, the application icon will *still* show up, just smaller, and to the side of the primary icon.

So if you really just want to use *your* icon, you need to build the project in XCode yourself. And even so, there are some issues about getting it to "know" that you've changed the icon.

Notification Center is picky about the icon it displays for your notification. If a notification has been sent previously, a subsequent icon change will not be detected or updated by Notification Center.

Therefore, my recommendation is to apply the icon you want before sending any notifications for the first time to avoid any hassles. If you get stuck with the wrong icon, you should be able to change the project Bundle Identifier in the project->General pane; or you can increment the build number in the same place.

See [here](http://stackoverflow.com/questions/11856766/osx-notification-center-icon) for more info.

#### The other nerdery
Normally, for a notification to be persistent (meaning, it stays onscreen until a button is clicked on the notification), the notification needs to be an "alert" style notification. However, Apple does not allow just anyone to make alerts. To use an alert in your app, the app has to be signed with a developer ID.

Or does it... There's another private API key that allows you to show buttons on a "banner", which is the default type, and available for unsigned apps. So that's what yo uses.

If that makes you nervous, add a key "NSUserNotificationAlertStyle" with value "alert" to the project's Info.plist and build the app, signed with your own developer ID.