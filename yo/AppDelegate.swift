//
//  AppDelegate.swift
//  yo
//
//  Created by Shea Craig on 2/24/15.
//  Copyright (c) 2015 Shea Craig. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var yoNotification: YoNotification?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let args = YoCommandLine()
        let yoNotification = YoNotification(arguments: args)
        
        // Wait a bit for the notification to post, then quit the app.
        sleep(2)
        exit(0)
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

