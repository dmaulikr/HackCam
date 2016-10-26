//
//  HCStaticTimer.swift
//  HackCam
//
//  Created by Alex Telek on 25/06/2015.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit

protocol HCStaticTimerDelegate {
    func didUpdateTimer()
}

class HCStaticTimer: NSObject {
    
    fileprivate let groupID = "group.a.HackCam.WatchKit"
    
    fileprivate var timer = Timer()
    fileprivate static var sharedInstance: HCStaticTimer?
    
    var elapseTime = 60
    var delegate: HCStaticTimerDelegate?
    
    /** Shared instance of the timer */
    class func sharedTimer() -> HCStaticTimer {
        if sharedInstance == nil {
            sharedInstance = HCStaticTimer()
        }
        return sharedInstance!
    }
    
    override init() {
        super.init()
        
        if let userDefaults = UserDefaults(suiteName: self.groupID) {
            elapseTime = userDefaults.integer(forKey: "timerValue")
        }
    }
    
    /** Start the timer statically so it is the same everywhere */
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HCStaticTimer.updateTime), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func endTimer() {
        timer.invalidate()
        resetTimer()
    }
    
    /** Reset timer after finished */
    fileprivate func resetTimer() {
        if let userDefaults = UserDefaults(suiteName: self.groupID) {
            elapseTime = userDefaults.integer(forKey: "timerValue")
        }
    }
    
    /** Update the elapse value and check weather it ended or not. 
    On the views if it's below 10 make it red. */
    func updateTime() {
        elapseTime -= 1
        
        if elapseTime <= -1 {
            endTimer()
        }
        
        delegate?.didUpdateTimer()
    }
    
    
    func isRunning() -> Bool {
        return timer.isValid
    }
}
