//
//  HC_Tutorial1.swift
//  HackCam
//
//  Created by Clarence Ji on 3/10/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit

class HC_Tutorial1: UIViewController {

    @IBOutlet var img_Background: UIImageView!
    @IBOutlet var img_OrientationLock: UIImageView!
    @IBOutlet var img_Tutorial3: UIImageView!
    @IBOutlet var btn_NextStep: UIButton!
    @IBOutlet var label_Description: UILabel!
    
    var iPhone6andLater = UserDefaults.standard.bool(forKey: "iPhone6andLater")
    
    var currentStep = 0
    var str_SecondStep = "2. Connect your iPhone to your Mac. Open QuickTime Player on Mac."
    var str_ThirdStep = "3. On QuickTime Player menu bar, click File > New Movie Recording. Click the arrow beside the recording button and choose your iPhone."
    var str_FourthStep = "4. For maximum quality, you can turn on 60 FPS recording in your phone settings."
    
    fileprivate var wormhole: MMWormhole!
    fileprivate let groupID = "group.a.HackCam.WatchKit"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = UIScreen.main.bounds
        
        wormhole = MMWormhole(applicationGroupIdentifier: self.groupID, optionalDirectory: nil)
        
        // Parallax Effect
        let verticalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        let horizontalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        let motionEffectGroup: UIMotionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [verticalMotionEffect, horizontalMotionEffect]
        verticalMotionEffect.minimumRelativeValue = -15
        verticalMotionEffect.maximumRelativeValue = 15
        horizontalMotionEffect.minimumRelativeValue = -15
        horizontalMotionEffect.maximumRelativeValue = 15
        img_Background.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        img_Background.motionEffects = [motionEffectGroup]

        // Button Style
        btn_NextStep.backgroundColor = UIColor(red: 0, green: 192/255, blue: 209/255, alpha: 0.20)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let blurEffectView_Frame = CGRect(x: btn_NextStep.bounds.origin.x, y: btn_NextStep.bounds.origin.y, width: 150, height: 45)
        blurEffectView.frame = blurEffectView_Frame
        blurEffectView.alpha = 0.75
        blurEffectView.layer.cornerRadius = 3
        blurEffectView.isUserInteractionEnabled = false
        btn_NextStep.addSubview(blurEffectView)
        btn_NextStep.sendSubview(toBack: blurEffectView)
        btn_NextStep.layer.cornerRadius = 3
        btn_NextStep.clipsToBounds = true
        
    }
    
    @IBAction func btn_NextStepClicked(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            switch self.currentStep {
            case 0:
                self.animateDescription(self.str_SecondStep)
                self.animateIcons()
                
                self.currentStep += 1
                
            case 1:
                self.animateDescription(self.str_ThirdStep)
                self.animateIcons()
                
                self.currentStep += 1
                if !self.iPhone6andLater {
                    self.btn_NextStep.setTitle("Finish", for: UIControlState())
                }
                
            case 2:
                if self.iPhone6andLater {
                    self.animateDescription(self.str_FourthStep)
                    self.animateIcons()
                    
                    self.currentStep += 1
                    self.btn_NextStep.setTitle("Finish", for: UIControlState())
                } else {
                    self.finishTutorial()
                }
                
            case 3:
                self.finishTutorial()
                
            default:
                break
            }
        })
        
    }
    
    func animateDescription(_ string: String) {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.label_Description.alpha = 0.0
            }, completion: { (complete: Bool) -> Void in
                self.label_Description.text = string
                UIView.animate(withDuration: 0.4, animations: {
                    self.label_Description.alpha = 0.6
                }, completion: nil)
        }) 
    }
    
    func animateIcons() {
        let img_QuickTime = UIImage(named: "img_QuickTime")
        let img_Tutorial4 = UIImage(named: "img_Tutorial4")
        if self.currentStep == 2 && self.iPhone6andLater {
            UIView.transition(with: self.img_Tutorial3, duration: 0.8, options: .transitionCrossDissolve, animations: {
                self.img_Tutorial3.image = img_Tutorial4
                self.img_Tutorial3.alpha == 0.9
            }, completion: nil)
        } else {
            UIView.transition(with: self.img_OrientationLock,
                duration: 0.8,
                options: .transitionCrossDissolve,
                animations: {
                    if self.currentStep == 0 {
                        self.img_OrientationLock.image = img_QuickTime
                        self.img_OrientationLock.alpha = 0.9
                    } else {
                        self.img_OrientationLock.alpha = 0
                        self.img_Tutorial3.alpha = 0.8
                    }
                    
                },
                completion: nil)
        }
        
    }
    
    func finishTutorial() {
        print("send message")
        wormhole.passMessageObject(["value":true] as NSCoding, identifier: "tutorial")
        
        UserDefaults(suiteName: self.groupID)?.set(true, forKey: "tutorialSkipped")
        
        let cameraView = self.storyboard!.instantiateViewController(withIdentifier: "CameraView") as! HC_MainViewController
        self.present(cameraView, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
