//
//  AppDelegate.swift
//  yo
//
//  Created by Shea Craig on 2/24/15.
//  Copyright (c) 2015 Soap Zombie. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()

        // For now, cmdline arg processing is VERY unfinished. Expects
        // arguments in order: title, subtitle, informativeText, actionButtonTitle
        notification.title = Process.arguments[1]
        notification.subtitle = Process.arguments[2]
        notification.informativeText = Process.arguments[3]
        //notification.contentImage = NSImage(contentsOfFile: "/Users/scraig/Desktop/Lo-Pan.jpg")
        notification.hasActionButton = true
        notification.actionButtonTitle = Process.arguments[4]
        
        // Set delivery time in the future and configure notification.
        let deliveryTime = NSDate().dateByAddingTimeInterval(5)
        notification.deliveryDate = deliveryTime
        
        // Schedule notification with the notification center.
        let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
        nc.delegate = self
        nc.scheduleNotification(notification)

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func userNotificationCenter(center: NSUserNotificationCenter!, didActivateNotification notification: NSUserNotification!) {
        // At the moment, just quit.
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

