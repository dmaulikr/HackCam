//
//  TimerInterfaceController.swift
//  HackCam
//
//  Created by Alex Telek on 11/06/2015.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import WatchKit
import Foundation


class TimerInterfaceController: WKInterfaceController {

    fileprivate let groupID = "group.a.HackCam.WatchKit"
    
    fileprivate let kTimeLevel = 10
    
    @IBOutlet weak var lblTimer: WKInterfaceLabel!
    
    // Timer value to increase and decrease
    fileprivate static var time = 60
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if let userDefaults = UserDefaults(suiteName: self.groupID) {
            TimerInterfaceController.time = userDefaults.integer(forKey: "timerValue")
            lblTimer.setText(TimerInterfaceController.convertValueToString())
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    class func convertValueToString() -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time % 60)
        
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        } else {
            return "\(minutes):\(seconds)"
        }
    }
    
    class func convertValueToString(_ value: Int) -> String {
        TimerInterfaceController.time = value
        return convertValueToString()
    }
    
    @IBAction func removeTime() {
        if TimerInterfaceController.time > 20 {
            TimerInterfaceController.time -= kTimeLevel
            lblTimer.setText(TimerInterfaceController.convertValueToString())
        }
    }
    
    @IBAction func addTime() {
        if TimerInterfaceController.time < 300 {
            TimerInterfaceController.time += kTimeLevel
            lblTimer.setText(TimerInterfaceController.convertValueToString())
        }
    }
    
    @IBAction func updateTime() {
        if let userDefaults = UserDefaults(suiteName: self.groupID) {
            userDefaults.set(TimerInterfaceController.time, forKey: "timerValue")
            HCStaticTimer.sharedTimer().elapseTime = TimerInterfaceController.time
            dismiss()
        }
    }
}
