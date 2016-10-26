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
    
    fileprivate let groupID = "group.a.HackCam.WatchKit"
    
    fileprivate let timer = HCStaticTimer.sharedTimer()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        timer.delegate = self
        
        // Configure interface objects here.
        WKInterfaceController.openParentApplication([:], reply: { (reply, error) -> Void in
            if error == nil && reply["logo"] != nil {
                self.imgLogo.setImage(UIImage(data: (reply["logo"] as? Data)!))
            }
        })
        
        // Set the timer
        if timer.isRunning() {
            lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
        } else if let userDefaults = UserDefaults(suiteName: self.groupID) {
            lblTimer.setText(TimerInterfaceController.convertValueToString(userDefaults.integer(forKey: "timerValue")))
        }
        
        // Set the description title
        if let userDefaults = UserDefaults(suiteName: self.groupID) {
            let time = userDefaults.integer(forKey: "timerValue")
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
            lblTimer.setTextColor(UIColor.red)
        }
        
        // reset the timer at the end
        if timer.elapseTime <= 0 {
            lblTimer.setTextColor(UIColor.white)
        }
        
        lblTimer.setText(TimerInterfaceController.convertValueToString(timer.elapseTime))
    }

}
