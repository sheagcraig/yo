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

        // General properties.
        
        // This option does not currently work to make a banner.
        if !arguments.banner.value {
            // Overrides default notification style of "banner" to show buttons.
            // Otherwise, to change to an "alert", app needs to be signed with a developer ID.
            // See http://stackoverflow.com/a/23087567 and http://stackoverflow.com/a/12012934
            notification.setValue(true, forKey: "_showsButtons")
        }
        
        // If set, _ignoreDoNotDisturb will deliver a notification even when in DND mode.
        notification.setValue(arguments.ignoresDoNotDisturb.value, forKey: "_ignoresDoNotDisturb")
        // If set, _lockscreenOnly will ONLY deliver a notification to a locked screen.
        // Lockscreen notifications cannot have buttons (so if configured, they won't show up).
        notification.setValue(arguments.lockscreenOnly.value, forKey: "_lockscreenOnly")
        
        // Delivery sound.
        if let deliverySound = arguments.deliverySound.value {
            notification.soundName = deliverySound
        }
        
        // Image elements.
        
        // Alternate icon handling.
        if let iconPath = arguments.icon.value {
            notification.setValue(NSImage(byReferencingURL: NSURL(fileURLWithPath: iconPath)!), forKey: "_identityImage")
            notification.setValue(false, forKey: "_identityImageHasBorder")
        }
        
        // Content image.
        if let contentImagePath = arguments.contentImage.value {
            notification.contentImage = NSImage(byReferencingURL: NSURL(fileURLWithPath: contentImagePath)!)
        }
        
        // Text elements.
        notification.title = arguments.title.value
        notification.subtitle = arguments.subtitle.value
        notification.informativeText = arguments.informativeText.value
        
        // Button elements.

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

        notification.setValue(arguments.poofsOnCancel.value, forKey: "_poofsOnCancel")
       
        let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
        nc.delegate = self
        nc.deliverNotification(notification)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        // Open something if configured.
        if action != nil {
            let task = NSTask()
            task.launchPath = "/usr/bin/open"
            task.arguments = [action!]
            task.launch()
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didDeliverNotification notification: NSUserNotification) {
        // Pass
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        // Ensure that notification is shown, even if app is active.
        return true
    }

}