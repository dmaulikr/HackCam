//
//  AppDelegate.swift
//  HackCam
//
//  Created by Clarence Ji on 2/26/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    fileprivate var wormhole: MMWormhole!
    fileprivate let groupID = "group.a.HackCam.WatchKit"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Determine iPhone Model
        var systemInfo = [UInt8](repeating: 0, count: sizeof(utsname))
        let model: String = systemInfo.withUnsafeMutableBufferPointer { (body: inout UnsafeMutableBufferPointer<UInt8>) -> String? in
            if uname(UnsafeMutablePointer(body.baseAddress)) != 0 {
                return nil
            }
            return String(cString: UnsafePointer(body.baseAddress.advanced(by: Int(_SYS_NAMELEN * 4))))
            }!
        print(Array(model.characters))
        let modelArray = Array(model.characters)
        if modelArray.count > 6 {
            if Int(String(Array(model.characters)[6])) >= 7 {
                UserDefaults.standard.set(true, forKey: "iPhone6andLater")
            } else {
                UserDefaults.standard.set(false, forKey: "iPhone6andLater")
            }
        } else {
            UserDefaults.standard.set(false, forKey: "iPhone6andLater")
        }
        
        // Register notification
        wormhole = MMWormhole(applicationGroupIdentifier: self.groupID, optionalDirectory: nil)
        
        let ud = UserDefaults(suiteName: self.groupID)
        if let bool = ud?.bool(forKey: "tutorialSkipped") {
            if bool {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "CameraView") as! HC_MainViewController
                
                self.window?.rootViewController = viewController
                self.window?.makeKeyAndVisible()
            }
        }
        
        // Set initial timer value at the beggining
        if let userDefaults = ud {
            if userDefaults.integer(forKey: "timerValue") == 0 { userDefaults.set(60, forKey: "timerValue") }
        }
        
        return true
    }

    func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?, reply: (@escaping ([AnyHashable: Any]?) -> Void)) {
        
        var retValues = Dictionary<String,Data>()
        
        if let userDefaults = UserDefaults(suiteName: self.groupID) {
            retValues["logo"] = userDefaults.object(forKey: "storedLogoImage") as? Data
        }
        
        reply(retValues)
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        wormhole.passMessageObject(["value":false], identifier: "open")
        UserDefaults(suiteName: self.groupID)?.set(false, forKey: "open")
        
        wormhole.stopListeningForMessage(withIdentifier: "blurMode")
    }

}

