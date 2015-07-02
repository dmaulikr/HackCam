//
//  AppDelegate.swift
//  HackCam
//
//  Created by Clarence Ji on 2/26/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var wormhole: MMWormhole!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Determine iPhone Model
        var systemInfo = [UInt8](count: sizeof(utsname), repeatedValue: 0)
        let model: String = systemInfo.withUnsafeMutableBufferPointer { (inout body: UnsafeMutableBufferPointer<UInt8>) -> String? in
            if uname(UnsafeMutablePointer(body.baseAddress)) != 0 {
                return nil
            }
            return String.fromCString(UnsafePointer(body.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))))
            }!
        println(Array(model))
        let modelArray = Array(model)
        if modelArray.count > 6 {
            if String(Array(model)[6]).toInt() >= 7 {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "iPhone6andLater")
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "iPhone6andLater")
            }
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "iPhone6andLater")
        }
        
        // Register notification
        wormhole = MMWormhole(applicationGroupIdentifier: "group.hackcam.watchKit", optionalDirectory: nil)
        
        let ud = NSUserDefaults(suiteName: "group.hackcam.watchKit")
        if let bool = ud?.boolForKey("tutorialSkipped") {
            if bool {
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewControllerWithIdentifier("CameraView") as! HC_MainViewController
                
                self.window?.rootViewController = viewController
                self.window?.makeKeyAndVisible()
            }
        }
        
        // Set initial timer value at the beggining
        if let userDefaults = ud {
            if userDefaults.integerForKey("timerValue") == 0 { userDefaults.setInteger(60, forKey: "timerValue") }
        }
        
        return true
    }

    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        
        var retValues = Dictionary<String,NSData>()
        
        if let userDefaults = NSUserDefaults(suiteName: "group.hackcam.watchKit") {
            retValues["logo"] = userDefaults.objectForKey("storedLogoImage") as? NSData
        }
        
        reply(retValues)
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        wormhole.passMessageObject(["value":false], identifier: "open")
        NSUserDefaults(suiteName: "group.hackcam.watchKit")?.setBool(false, forKey: "open")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Call notification
        self.wormhole.passMessageObject(["value":true], identifier: "open")
        NSUserDefaults(suiteName: "group.hackcam.watchKit")?.setBool(true, forKey: "open")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        wormhole.passMessageObject(["value":false], identifier: "open")
        NSUserDefaults(suiteName: "group.hackcam.watchKit")?.setBool(false, forKey: "open")
        
        wormhole.stopListeningForMessageWithIdentifier("blurMode")
    }

}

