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


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Handle commandline arguments to fill our notification
        let cli = CommandLine()
        
        let title = StringOption(shortFlag: "t", longFlag: "title", required: true, helpMessage: "Title for notification")
        let subtitle = StringOption(shortFlag: "s", longFlag: "subtitle", required: false, helpMessage: "Subtitle for notification")
        let informative_text = StringOption(shortFlag: "i", longFlag: "itext", required: false, helpMessage: "Informative text.")
        let action_btn_text = StringOption(shortFlag: "b", longFlag: "btext", required: false, helpMessage: "Action button text.")
        
        cli.addOptions(title, subtitle, informative_text, action_btn_text)
        let (success, error) = cli.parse()
        
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()

        // For now, cmdline arg processing is VERY unfinished. Expects
        // arguments in order: title, subtitle, informativeText, actionButtonTitle
        notification.title = title.value
        notification.subtitle = subtitle.value?
        notification.informativeText = informative_text.value?

        if let btn_text = action_btn_text.value? {
            notification.hasActionButton = true
            notification.actionButtonTitle = btn_text
        }
        else {
            notification.hasActionButton = false
        }

        //notification.contentImage = NSImage(contentsOfFile: "/Users/scraig/Desktop/Lo-Pan.jpg")

        // Schedule notification with the notification center.
        let nc = NSUserNotificationCenter.defaultUserNotificationCenter()
        nc.delegate = self
        nc.deliverNotification(notification)
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func userNotificationCenter(center: NSUserNotificationCenter!, didActivateNotification notification: NSUserNotification!) {
        // Open something
        let task = NSTask()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["/Applications/Self Service.app"]
        task.launch()
        
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

