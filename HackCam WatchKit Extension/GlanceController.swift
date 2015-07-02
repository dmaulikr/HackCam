//
//  GlanceController.swift
//  HackCam WatchKit Extension
//
//  Created by Alex Telek on 11/06/2015.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController, HCStaticTimerDelegate {

    @IBOutlet weak var lblTimer: WKInterfaceLabel!
    @IBOutlet weak var imgLogo: WKInterfaceImage!
    @IBOutlet weak var lblDesc: WKInterfaceLabel!
    
    private let groupID = "group.a.HackCam.WatchKit"
    
    private let timer = HCStaticTimer.sharedTimer()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        timer.delegate = self
        
        // Configure interface objects here.
        WKInterfaceController.openParentApplication([:], reply: { (reply, error) -> Void in
            if error == nil && reply["logo"] != nil {
                self.imgLogo.setImage(UIImage(data: (reply["logo"] as? NSData)!))
            }
        })
        
        // Set the timer
        if timer.isRunning() {
            lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
        } else if let userDefaults = NSUserDefaults(suiteName: self.groupID) {
            lblTimer.setText(TimerInterfaceController.convertValueToString(userDefaults.integerForKey("timerValue")))
        }
        
        // Set the description title
        if let userDefaults = NSUserDefaults(suiteName: self.groupID) {
            let time = userDefaults.integerForKey("timerValue")
            if time < 60 {
                lblDesc.setText("The timer is currently set to \(time) seconds. Change it on your iPhone.")
            } else {
                lblDesc.setText("The timer is currently set to \(time) minute(s). Change it on your iPhone.")
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func didUpdateTimer() {
        // set red alert when getting closer to the end
        if timer.elapseTime < 10 && timer.isRunning() {
            lblTimer.setTextColor(UIColor.redColor())
        }
        
        // reset the timer at the end
        if timer.elapseTime <= 0 {
            lblTimer.setTextColor(UIColor.whiteColor())
        }
        
        lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
    }

}
