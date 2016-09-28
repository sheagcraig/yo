//
//  AppDelegate.swift
//  yo
//
//  Created by Shea Craig on 2/24/15.
//  Copyright (c) 2015 Shea Craig. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let nc = NSUserNotificationCenter.default
        nc.delegate = self

        // If notification is activated (i.e. user clicked the action button) the app will relaunch.
        // Test for that, and if so, execute the option tucked away in the userInfo dict.
        if let notification = (aNotification as NSNotification).userInfo![NSApplicationLaunchUserNotificationKey] as? NSUserNotification {
            let task = Process()
            // It's safe to just open nothing, so this is the default.
            task.launchPath = "/usr/bin/open"
            if let action = notification.userInfo!["action"] as? String {
                NSLog("User activated notification with action: \(action)")
                task.arguments = [action]
            }

            if let bashAction = notification.userInfo!["bashAction"] as? String {
                task.launchPath = "/bin/bash"
                NSLog("User activated notification with action: \(bashAction)")
                task.arguments = ["-c", bashAction]
            }

            task.launch()
            // We're done.
            exit(0)
        }
        else {
            let args = YoCommandLine()
            NSLog("Posting notification.")
            _ = YoNotification(arguments: args)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        // Work is done, time to quit.
        exit(0)
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        // Ensure that notification is shown, even if app is active.
        return true
    }
}
