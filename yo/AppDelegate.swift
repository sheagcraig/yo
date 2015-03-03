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
        let yo = YoNotification()
        
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()
        notification.title = yo.title.value
        notification.subtitle = yo.subtitle.value?
        notification.informativeText = yo.informativeText.value?

        // Add action button and text if a value is supplied.
        if let btnText = yo.actionBtnText.value {
            notification.hasActionButton = true
            notification.actionButtonTitle = btnText
        }
        else {
            notification.hasActionButton = false
        }
        
        // Optional Other button (defaults to "Cancel")
        if let otherBtnTitle = yo.otherBtnText.value {
            notification.otherButtonTitle = otherBtnTitle
        }
        
        // Action button application
        self.actionPath = yo.action.value

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

