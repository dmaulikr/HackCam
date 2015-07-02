//
//  WelcomeInterfaceController.swift
//  HackCam
//
//  Created by Alex Telek on 26/06/2015.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import WatchKit
import Foundation


class WelcomeInterfaceController: WKInterfaceController {

    private var wormhole: MMWormhole!
    
    private let groupID = "group.a.HackCam.WatchKit"
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        if let bool = NSUserDefaults(suiteName: self.groupID)?.boolForKey("tutorialSkipped") {
            if bool {
                WKInterfaceController.reloadRootControllersWithNames(["mainView"], contexts: nil)
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        wormhole = MMWormhole(applicationGroupIdentifier: self.groupID, optionalDirectory: nil)
        
        wormhole.listenForMessageWithIdentifier("tutorial", listener: { (messageObject) -> Void in
            if let message: AnyObject = messageObject {
                WKInterfaceController.reloadRootControllersWithNames(["mainView"], contexts: nil)
            }
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        if wormhole != nil {
            println("stop listening?")
            self.wormhole.stopListeningForMessageWithIdentifier("tutorial")
        }
    }

}
