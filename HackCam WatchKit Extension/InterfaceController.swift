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

    fileprivate let kBeginText = "Begin"
    fileprivate let kEndText = "End"
    
    @IBOutlet weak var lblTimer: WKInterfaceLabel!
    @IBOutlet weak var imgLogo: WKInterfaceImage!
    @IBOutlet weak var btnBegin: WKInterfaceButton!
    @IBOutlet weak var lblDescription: WKInterfaceLabel!
    
    fileprivate let groupID = "group.a.HackCam.WatchKit"
    
    fileprivate var isBlurModeOff = false
    fileprivate let timer = HCStaticTimer.sharedTimer()
    fileprivate var welcomeTimer = Timer()
    fileprivate var wormhole: MMWormhole!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        timer.delegate = self
        
        wormhole = MMWormhole(applicationGroupIdentifier: self.groupID, optionalDirectory: nil)
        
        if let userDefaults = UserDefaults(suiteName: self.groupID) {
            if userDefaults.bool(forKey: "open") {
                self.lblDescription.setHidden(true)
                self.btnBegin.setHidden(false)
            }
        }
        
        wormhole.listenForMessage(withIdentifier: "open", listener: { (messageObject) -> Void in
            if let message: AnyObject = messageObject as AnyObject? {
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
                self.imgLogo.setImage(UIImage(data: (reply["logo"] as? Data)!))
            }
        })
        
        if timer.isRunning() {
            lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
        } else if let userDefaults = UserDefaults(suiteName: self.groupID) {
            let elapseTime = userDefaults.integer(forKey: "timerValue")
            lblTimer.setText(TimerInterfaceController.convertValueToString(elapseTime))
            elapseTime == 0 ? btnBegin.setEnabled(false) : btnBegin.setEnabled(true)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        if wormhole != nil {
            print("stop listening?")
            wormhole.stopListeningForMessage(withIdentifier: "open")
        }
    }
    
    @IBAction func openTimer() {
        presentController(withName: "timerView", context: self)
    }
    
    // MANUAL START & FINISH
    @IBAction func beginTimer() {
        if isBlurModeOff {
            timer.endTimer()
            
            // end of presentation
            wormhole.passMessageObject(["value":true] as NSCoding, identifier: "blurMode")
            
            btnBegin.setTitle(kBeginText)
            lblTimer.setTextColor(UIColor.white)
        } else {
            timer.startTimer()
            
            // start of presentation
            wormhole.passMessageObject(["value":false] as NSCoding, identifier: "blurMode")
            
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
            lblTimer.setTextColor(UIColor.red)
        }
        
        // reset the timer at the end
        if timer.elapseTime <= 0 {
            // Reset data
            isBlurModeOff = !isBlurModeOff
            btnBegin.setTitle(kBeginText)
            lblTimer.setTextColor(UIColor.white)
            
            
            // end of presentation
            wormhole.passMessageObject(["value":true] as NSCoding, identifier: "blurMode")
        }
        
        lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
    }
    
}
