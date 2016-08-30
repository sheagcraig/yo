//
//  YoNotification.swift
//  yo
//
//  Created by Shea Craig on 3/3/15.
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

import Foundation
import Cocoa

class YoNotification: NSObject {

    init (arguments: YoCommandLine) {
        super.init()
        // Create a user notification object and set it's properties.
        let notification = NSUserNotification()

        // General properties.
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        print(bundleIdentifier)

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
            // If you pass a name that doesn't exist it will be nil anyway, but this allows us
            // to set None explicitly.
            if deliverySound == "None" {
                notification.soundName = nil
            }
            else {
                notification.soundName = deliverySound
            }
        }
        else {
            notification.soundName = NSUserNotificationDefaultSoundName
        }

        // Image elements.

        // Alternate icon handling.
        if let iconPath = arguments.icon.value {
            notification.setValue(NSImage(byReferencing: URL(fileURLWithPath: iconPath)), forKey: "_identityImage")
            notification.setValue(false, forKey: "_identityImageHasBorder")
        }

        // Content image.
        if let contentImagePath = arguments.contentImage.value {
            notification.contentImage = NSImage(byReferencing: URL(fileURLWithPath: contentImagePath))
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
        // Store the action (if provided) so we can retrieve it later.
        if let action = arguments.action.value {
            notification.userInfo = ["sender": bundleIdentifier]
            notification.userInfo = ["action": action]
        }
        if let bashAction = arguments.bashAction.value {
            notification.userInfo = ["sender": bundleIdentifier]
            notification.userInfo = ["bashAction": bashAction]
        }

        // Optional Other button (defaults to "Cancel")
        if let otherBtnTitle = arguments.otherBtnText.value {
            notification.otherButtonTitle = otherBtnTitle
        }

        notification.setValue(arguments.poofsOnCancel.value, forKey: "_poofsOnCancel")

        let nc = NSUserNotificationCenter.default
        nc.scheduleNotification(notification)
    }
}
