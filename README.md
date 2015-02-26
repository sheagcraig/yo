# yo


## Custom User Notifications with Swift

### Overview
```yo``` is a simple app for sending custom notifications to the Notification Center in OS X Yosemite. It allows customizing the various text fields and button labels, as well as the application to open when the (optional) action button has been clicked.

It differs from [terminal-notifier](https://github.com/alloy/terminal-notifier) in that it creates persistent (alert, rather than banner) notifications that remain in place until clicked. Also, as an alert, it gives you the option of customizing the clickable buttons.

### Build & Installation
1. Clone the project.
2. Open the project in XCode and set the App Icon to your desired icon. See the Icon section below for more info on this.
3. Build. (CMD-B)
4. Copy the built app (Contextual-click on the Products->yo.app->Show in Finder) wherever you see fit, although ```/Applications/Utilities``` seems like a suitable place.

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
      Action button text.
  -o, --obtext:  
      Alternate label for cancel button text.
  -a, --action:  
      Application to open if user selects the action button. Provide the full path as the argument.
  -h, --help:
	  Show help.
```

Notes:
- Title is mandatory. All other arguments are optional.
- The action argument needs a path or URL. yo just calls ```open```, so anything that would work there, should work here.
- Without the ```-b``` option, there will be no action button; only the cancel button. Thus, you need both ```-b``` and ```-a``` if you want custom actions.

### Example
```
# /Applications/Utilities/yo.app/Contents/MacOS/yo -t "Taco Time" -b "Yum" -a "http://en.wikipedia.org/wiki/Taco"
```

### Application Icon
Notification Center is picky about the icon it displays for your notification. Without using a private API, the icon is set via the application's icon. However, if a notification has been sent previously, a subsequent icon change will not be detected or updated by Notification Center.

Therefore, my recommendation is to apply the icon you want before sending any notifications for the first time to avoid any hassles. If you get stuck with the wrong icon, you should be able to change the project Bundle Identifier in the project->General pane; or you can increment the build number in the same place.

See [here](http://stackoverflow.com/questions/11856766/osx-notification-center-icon) for more info.
