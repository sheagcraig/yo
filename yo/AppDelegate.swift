//
//  AppDelegate.swift
//  yo
//
//  Created by Shea Craig on 2/24/15.
//  Copyright (c) 2015 Soap Zombie. All rights reserved.
//

import Cocoa
import Foundation
import CommandLine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    var actionPath: String?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Handle commandline arguments to fill our notification
        let cli = CommandLine()
        
        let title = StringOption(shortFlag: "t", longFlag: "title", required: true, helpMessage: "Title for notification")
        let subtitle = StringOption(shortFlag: "s", longFlag: "subtitle", required: false, helpMessage: "Subtitle for notification")
        let informativeText = StringOption(shortFlag: "i", longFlag: "info", required: false, helpMessage: "Informative text.")
        let actionBtnText = StringOption(shortFlag: "b", longFlag: "action_btn", required: false, helpMessage: "Action button text.")
        let otherBtnText = StringOption(shortFlag: "o", longFlag: "other_btn", required: false, helpMessage: "Alternate label for cancel button text.")
        let action = StringOption(shortFlag: "a", longFlag: "action_path", required: false, helpMessage: "Application to open if user selects the action button. Provide the full path as the argument.")
        let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Show help.")
        
        cli.addOptions(title, subtitle, informativeText, actionBtnText, otherBtnText, action)
        let (success, error) = cli.parse()
        if !success {
            println(error!)
            cli.printUsage()
            exit(EX_USAGE)
        }
        
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()
        notification.title = title.value
        notification.subtitle = subtitle.value?
        notification.informativeText = informativeText.value?

        // Add action button and text if a value is supplied.
        if let btnText = actionBtnText.value {
            notification.hasActionButton = true
            notification.actionButtonTitle = btnText
        }
        else {
            notification.hasActionButton = false
        }
        
        // Optional Other button (defaults to "Cancel")
        if let otherBtnTitle = otherBtnText.value {
            notification.otherButtonTitle = otherBtnTitle
        }
        
        // Action button application
        self.actionPath = action.value

        let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
        nc.delegate = self
        nc.deliverNotification(notification)
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func userNotificationCenter(center: NSUserNotificationCenter!, didActivateNotification notification: NSUserNotification!) {
        // Open something if configured.
        if self.actionPath != nil {
            let task = NSTask()
            task.launchPath = "/usr/bin/open"
            task.arguments = [self.actionPath!]
            task.launch()
        }
        
        // Exit the program so user doesn't see it in task manager.
        exit(0)

    }
    func userNotificationCenter(center: NSUserNotificationCenter!, didDeliverNotification notification: NSUserNotification!) {
        // Pass
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter!, shouldPresentNotification notification: NSUserNotification!) -> Bool {
        // Ensure that notification is shown, even if app is active.
        return true
    }
}

