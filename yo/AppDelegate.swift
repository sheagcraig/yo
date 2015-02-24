//
//  AppDelegate.swift
//  yo
//
//  Created by Shea Craig on 2/24/15.
//  Copyright (c) 2015 Soap Zombie. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()
        notification.title = "Taco Emergency"

        for argument in Process.arguments {
            println(argument)
        }
        
        notification.subtitle = "There are not enough tacos to sustain life."
        notification.informativeText = "In girum imus nocte et consumimur igni."
        notification.contentImage = NSImage(contentsOfFile: "/Users/scraig/Desktop/Lo-Pan.jpg")
        notification.hasActionButton = true
        notification.actionButtonTitle = "Buy Tacos"
        
        // Set delivery time in the future and configure notification.
        let deliveryTime = NSDate().dateByAddingTimeInterval(5)
        notification.deliveryDate = deliveryTime
        
        // Schedule notification with the notification center.
        NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification(notification)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

