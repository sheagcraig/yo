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
    var action_path: String = ""

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Handle commandline arguments to fill our notification
        let cli = CommandLine()
        
        let title = StringOption(shortFlag: "t", longFlag: "title", required: true, helpMessage: "Title for notification")
        let subtitle = StringOption(shortFlag: "s", longFlag: "subtitle", required: false, helpMessage: "Subtitle for notification")
        let informative_text = StringOption(shortFlag: "i", longFlag: "info", required: false, helpMessage: "Informative text.")
        let action_btn_text = StringOption(shortFlag: "b", longFlag: "action_btn", required: false, helpMessage: "Action button text.")
        let other_btn_text = StringOption(shortFlag: "o", longFlag: "other_btn", required: false, helpMessage: "Alternate label for cancel button text.")
        let action = StringOption(shortFlag: "a", longFlag: "action_path", required: false, helpMessage: "Application to open if user selects the action button. Provide the full path as the argument.")
        
        cli.addOptions(title, subtitle, informative_text, action_btn_text, other_btn_text, action)
        let (success, error) = cli.parse()
        if success != false {
            println(success)
            println(error!)
            println(other_btn_text.value?)
            cli.printUsage()
            exit(EX_USAGE)
        }
        
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()
        notification.title = title.value
        notification.subtitle = subtitle.value?
        notification.informativeText = informative_text.value?

        // Add action button and text if a value is supplied.
        if let btn_text = action_btn_text.value? {
            notification.hasActionButton = true
            notification.actionButtonTitle = btn_text
        }
        else {
            notification.hasActionButton = false
        }
        
        // Optional Other button (defaults to "Cancel")
        if let text = other_btn_text.value? {
            notification.otherButtonTitle = text
        }
        
        // Action button application
        if let action_path = action.value? {
            self.action_path = action_path
        }

        let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
        nc.delegate = self
        nc.deliverNotification(notification)
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func userNotificationCenter(center: NSUserNotificationCenter!, didActivateNotification notification: NSUserNotification!) {
        // Open something if configured.
        if self.action_path != "" {
            let task = NSTask()
            task.launchPath = "/usr/bin/open"
            task.arguments = [self.action_path]
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

