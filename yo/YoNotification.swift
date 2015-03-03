//
//  YoNotification.swift
//  yo
//
//  Created by Shea Craig on 3/3/15.
//  Copyright (c) 2015 Soap Zombie. All rights reserved.
//

import Foundation
import CommandLine

class YoNotification {
    // Handle commandline arguments to fill our notification
    let cli = CommandLine()
    
    let title = StringOption(shortFlag: "t", longFlag: "title", required: true, helpMessage: "Title for notification")
    let subtitle = StringOption(shortFlag: "s", longFlag: "subtitle", required: false, helpMessage: "Subtitle for notification")
    let informativeText = StringOption(shortFlag: "i", longFlag: "info", required: false, helpMessage: "Informative text.")
    let actionBtnText = StringOption(shortFlag: "b", longFlag: "action_btn", required: false, helpMessage: "Action button text.")
    let otherBtnText = StringOption(shortFlag: "o", longFlag: "other_btn", required: false, helpMessage: "Alternate label for cancel button text.")
    let action = StringOption(shortFlag: "a", longFlag: "action_path", required: false, helpMessage: "Application to open if user selects the action button. Provide the full path as the argument.")
    let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Show help.")
    
    init () {
        cli.addOptions(title, subtitle, informativeText, actionBtnText, otherBtnText, action, help)
        let (success, error) = cli.parse()
        if help.value {
            cli.printUsage()
            exit(EX_USAGE)
        }
        else if !success {
            println(error!)
            cli.printUsage()
            exit(EX_USAGE)
        }
    }
}