//
//  InterfaceController.swift
//  HackCam WatchKit Extension
//
//  Created by Alex Telek on 11/06/2015.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, HCStaticTimerDelegate {

    private let kBeginText = "Begin"
    private let kEndText = "End"
    
    @IBOutlet weak var lblTimer: WKInterfaceLabel!
    @IBOutlet weak var imgLogo: WKInterfaceImage!
    @IBOutlet weak var btnBegin: WKInterfaceButton!
    @IBOutlet weak var lblDescription: WKInterfaceLabel!
    
    private let groupID = "group.a.HackCam.WatchKit"
    
    private var isBlurModeOff = false
    private let timer = HCStaticTimer.sharedTimer()
    private var welcomeTimer = NSTimer()
    private var wormhole: MMWormhole!
    
    override func awakeWithContext(context: AnyObject?) {
        // Configure interface objects here.
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        timer.delegate = self
        
        wormhole = MMWormhole(applicationGroupIdentifier: self.groupID, optionalDirectory: nil)
        
        if let userDefaults = NSUserDefaults(suiteName: self.groupID) {
            if userDefaults.boolForKey("open") {
                self.lblDescription.setHidden(true)
                self.btnBegin.setHidden(false)
            }
        }
        
        wormhole.listenForMessageWithIdentifier("open", listener: { (messageObject) -> Void in
            if let message: AnyObject = messageObject {
                let isOpen = message["value"] as! Bool
                if isOpen {
                    self.lblDescription.setHidden(true)
                    self.btnBegin.setHidden(false)
                } else {
                    self.lblDescription.setHidden(false)
                    self.btnBegin.setHidden(true)
                }
            }
        })
        
        WKInterfaceController.openParentApplication([:], reply: { (reply, error) -> Void in
            if error == nil && reply["logo"] != nil {
                self.imgLogo.setImage(UIImage(data: (reply["logo"] as? NSData)!))
            }
        })
        
        if timer.isRunning() {
            lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
        } else if let userDefaults = NSUserDefaults(suiteName: self.groupID) {
            let elapseTime = userDefaults.integerForKey("timerValue")
            lblTimer.setText(TimerInterfaceController.convertValueToString(elapseTime))
            elapseTime == 0 ? btnBegin.setEnabled(false) : btnBegin.setEnabled(true)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        if wormhole != nil {
            print("stop listening?")
            wormhole.stopListeningForMessageWithIdentifier("open")
        }
    }
    
    @IBAction func openTimer() {
        presentControllerWithName("timerView", context: self)
    }
    
    // MANUAL START & FINISH
    @IBAction func beginTimer() {
        if isBlurModeOff {
            timer.endTimer()
            
            // end of presentation
            wormhole.passMessageObject(["value":true], identifier: "blurMode")
            
            btnBegin.setTitle(kBeginText)
            lblTimer.setTextColor(UIColor.whiteColor())
        } else {
            timer.startTimer()
            
            // start of presentation
            wormhole.passMessageObject(["value":false], identifier: "blurMode")
            
            btnBegin.setTitle(kEndText)
        }
        
        isBlurModeOff = !isBlurModeOff
        lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
    }
    
    // MARK: HCStaticTimerDelegate
    
    // AUTOMATIC FINISH
    func didUpdateTimer() {
        // set red alert when getting closer to the end
        if timer.elapseTime < 10 && timer.isRunning() {
            lblTimer.setTextColor(UIColor.redColor())
        }
        
        // reset the timer at the end
        if timer.elapseTime <= 0 {
            // Reset data
            isBlurModeOff = !isBlurModeOff
            btnBegin.setTitle(kBeginText)
            lblTimer.setTextColor(UIColor.whiteColor())
            
            
            // end of presentation
            wormhole.passMessageObject(["value":true], identifier: "blurMode")
        }
        
        lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
    }
    
}
