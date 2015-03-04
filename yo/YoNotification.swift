//
//  YoNotification.swift
//  yo
//
//  Created by Shea Craig on 3/3/15.
//  Copyright (c) 2015 Shea Craig. All rights reserved.
//

import Foundation
import Cocoa

class YoNotification: NSObject, NSUserNotificationCenterDelegate {
    var action: String?
    
    init (arguments: YoCommandLine) {
        super.init()
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()
        notification.title = arguments.title.value
        notification.subtitle = arguments.subtitle.value?
        notification.informativeText = arguments.informativeText.value?
        
        // Add action button and text if a value is supplied.
        if let btnText = arguments.actionBtnText.value {
            notification.hasActionButton = true
            notification.actionButtonTitle = btnText
        }
        else {
            notification.hasActionButton = false
        }
        action = arguments.action.value
        
        // Optional Other button (defaults to "Cancel")
        if let otherBtnTitle = arguments.otherBtnText.value {
            notification.otherButtonTitle = otherBtnTitle
        }

//        notification.contentImage = NSImage(byReferencingURL: NSURL(fileURLWithPath: "/Users/scraig/Desktop/OracleJava8.png")!)
//        notification.setValue(NSImage(byReferencingURL: NSURL(fileURLWithPath: "/Users/scraig/Desktop/OracleJava8.png")!), forKey: "_identityImage")
//        notification.setValue(false, forKey: "_identityImageHasBorder")

        // Overrides default notification style of "banner" to show buttons.
        // Otherwise, to change to an "alert", app needs to be signed with a developer ID.
        // See http://stackoverflow.com/a/23087567 and http://stackoverflow.com/a/12012934
        notification.setValue(true, forKey: "_showsButtons")
        
        let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
        nc.delegate = self
        nc.deliverNotification(notification)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter!, didActivateNotification notification: NSUserNotification!) {
        // Open something if configured.
        if action != nil {
            let task = NSTask()
            task.launchPath = "/usr/bin/open"
            task.arguments = [action!]
            task.launch()
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter!, didDeliverNotification notification: NSUserNotification!) {
        // Pass
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter!, shouldPresentNotification notification: NSUserNotification!) -> Bool {
        // Ensure that notification is shown, even if app is active.
        return true
    }

}