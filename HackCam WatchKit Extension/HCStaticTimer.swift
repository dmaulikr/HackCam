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
    
    private var timer = NSTimer()
    private static var sharedInstance: HCStaticTimer?
    
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
        
        if let userDefaults = NSUserDefaults(suiteName: "group.hackcam.watchKit") {
            elapseTime = userDefaults.integerForKey("timerValue")
        }
    }
    
    /** Start the timer statically so it is the same everywhere */
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func endTimer() {
        timer.invalidate()
        resetTimer()
    }
    
    /** Reset timer after finished */
    private func resetTimer() {
        if let userDefaults = NSUserDefaults(suiteName: "group.hackcam.watchKit") {
            elapseTime = userDefaults.integerForKey("timerValue")
        }
    }
    
    /** Update the elapse value and check weather it ended or not. 
    On the views if it's below 10 make it red. */
    func updateTime() {
        elapseTime--
        
        if elapseTime <= -1 {
            endTimer()
        }
        
        delegate?.didUpdateTimer()
    }
    
    
    func isRunning() -> Bool {
        return timer.valid
    }
}
