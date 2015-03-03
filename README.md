# yo

## Custom User Notifications with Swift

### Overview
```yo``` is a simple app for sending custom, *persistent* notifications to the Notification Center in OS X Yosemite. It allows customizing the various text fields and button labels, as well as the application to open when the (optional) action button has been clicked. Further, it allows you to configure the application icon to be displayed with the notification.

It differs from [terminal-notifier](https://github.com/alloy/terminal-notifier) in that it creates persistent (alert, rather than banner) notifications that remain in place until clicked. Also, as an alert, it gives you the option of customizing the clickable buttons.

If you just want a notification, download the current installer package from the [releases](https://github.com/sheagcraig/yo/releases) page.

If you want to customize the icon/app name/etc, follow the Build & Installation instructions below.

### Build & Installation
1. Clone the project.
2. Open the project in XCode and set the App Icon to your desired icon. See the Icon section below for more info on this.
3. Build. (CMD-B)
4. Copy the built app (Contextual-click on the Products->yo.app->Show in Finder) wherever you see fit, although ```/Applications/Utilities``` seems like a suitable place.

Note: If you Run/(CMD-R) from XCode, it will just report back usage with a commandline parsing error. Just ignore that and run from the commandline.

### Usage
You must call the app from the commandline, from the actual binary inside. Feel free to alias or ln to this file to avoid the long filename in the future.

```
Usage: /Applications/Utilities/yo.app/Contents/MacOS/yo [options]
  -t, --title:
      Title for notification
  -s, --subtitle:
      Subtitle for notification
  -i, --itext:
      Informative text.
  -b, --btext:
	  Include an action button, with the button label text supplied to this argument.
  -o, --obtext:  
      Alternate label for cancel button text.
  -a, --action:  
      Application to open if user selects the action button. Provide the full path as the argument. This option only does something if -b/--action_btn is also specified. Defaults to opening nothing.
  -h, --help:
	  Show help.
```

Notes:
- Title is mandatory. All other arguments are optional.
- The action argument needs a path or URL. yo just calls ```open```, so anything that would work there, should work here.
- If a "cancel" button doesn't make sense for your needs, but you don't want two buttons on your notification, just use ```-o/--obtext``` with a label that seems appropriate, like "Accept", or perhaps "Confirm", but no ```-b/--btext```.

### Examples
```
# Example of basic notification:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time"

# Example with lots of text:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -s "Chorizo is best." -i "Although I also enjoy al pastor of course."

# Example with action button, opening a webpage in your default browser:
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -b "Yum" -a "http://en.wikipedia.org/wiki/Taco"

# Example opening an app: 
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -b "Yum" -a "/Applications/TacoParty.app"

# Example-What if you want a one-button persistent notification that doesn't *do* anything?
/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -o "Accept"
```

### Application Icon
Notification Center is picky about the icon it displays for your notification. Without using a private API, the icon is set via the application's icon. However, if a notification has been sent previously, a subsequent icon change will not be detected or updated by Notification Center.

Therefore, my recommendation is to apply the icon you want before sending any notifications for the first time to avoid any hassles. If you get stuck with the wrong icon, you should be able to change the project Bundle Identifier in the project->General pane; or you can increment the build number in the same place.

See [here](http://stackoverflow.com/questions/11856766/osx-notification-center-icon) for more info.

To change the icon provided with yo, open the project in XCode and navigate to the Images.xcassets file in the file browser. Simply drag a 128x128px replacement png over the one already in place. Optionally, if you want *more* icon sizes, feel free to go nuts and fill them all in.
