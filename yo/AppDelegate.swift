//
//  AppDelegate.swift
//  yo
//
//  Created by Shea Craig on 2/24/15.
//  Copyright (c) 2015 Shea Craig. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let nc = NSUserNotificationCenter.defaultUserNotificationCenter()

        // If notification is activated (i.e. user clicked the action button) the app will relaunch.
        // Test for that, and if so, execute the option tucked away in the userInfo dict.
        if let notification: NSUserNotification = aNotification.userInfo![NSApplicationLaunchUserNotificationKey] as? NSUserNotification {
            let task = NSTask()
            task.launchPath = "/usr/bin/open"
            if let action = notification.userInfo!["action"] as? String {
                task.arguments = [action]
            }

            task.launch()
            // We're done.
            exit(0)
        }
        else {
            let args = YoCommandLine()
            let yoNotification = YoNotification(arguments: args)
            nc.delegate = self
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didDeliverNotification notification: NSUserNotification) {
        // Work is done, time to quit.
        exit(0)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        // Ensure that notification is shown, even if app is active.
        return true
    }
}

