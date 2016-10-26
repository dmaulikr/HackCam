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

    fileprivate var wormhole: MMWormhole!
    
    fileprivate let groupID = "group.a.HackCam.WatchKit"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        if let bool = UserDefaults(suiteName: self.groupID)?.bool(forKey: "tutorialSkipped") {
            if bool {
                WKInterfaceController.reloadRootControllers(withNames: ["mainView"], contexts: nil)
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        wormhole = MMWormhole(applicationGroupIdentifier: self.groupID, optionalDirectory: nil)
        
        wormhole.listenForMessage(withIdentifier: "tutorial", listener: { (messageObject) -> Void in
            if let _: AnyObject = messageObject as AnyObject? {
                WKInterfaceController.reloadRootControllers(withNames: ["mainView"], contexts: nil)
            }
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        if wormhole != nil {
            print("stop listening?")
            self.wormhole.stopListeningForMessage(withIdentifier: "tutorial")
        }
    }

}
