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
    var yoNotification: YoNotification?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let args = YoCommandLine()
        let yoNotification = YoNotification(arguments: args)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        // Open something if configured.
//        if action != nil {
//            let task = NSTask()
//            task.launchPath = "/usr/bin/open"
//            task.arguments = [action!]
//            task.launch()
//        }
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

