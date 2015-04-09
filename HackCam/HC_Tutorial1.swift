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
    
    var iPhone6andLater = NSUserDefaults.standardUserDefaults().boolForKey("iPhone6andLater")
    
    var currentStep = 0
    var str_SecondStep = "2. Connect your iPhone to your Mac. Open QuickTime Player on Mac."
    var str_ThirdStep = "3. On QuickTime Player menu bar, click File > New Screen Recording. Click the arrow beside the recording button and choose your iPhone."
    var str_FourthStep = "4. For maximum quality, you can turn on 60 FPS recording in your phone settings."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = UIScreen.mainScreen().bounds
        
        // Parallax Effect
        var verticalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        var horizontalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        var motionEffectGroup: UIMotionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [verticalMotionEffect, horizontalMotionEffect]
        verticalMotionEffect.minimumRelativeValue = -15
        verticalMotionEffect.maximumRelativeValue = 15
        horizontalMotionEffect.minimumRelativeValue = -15
        horizontalMotionEffect.maximumRelativeValue = 15
        img_Background.transform = CGAffineTransformMakeScale(1.05, 1.05)
        img_Background.motionEffects = [motionEffectGroup]

        // Button Style
        btn_NextStep.backgroundColor = UIColor(red: 0, green: 192/255, blue: 209/255, alpha: 0.20)
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let blurEffectView_Frame = CGRectMake(btn_NextStep.bounds.origin.x, btn_NextStep.bounds.origin.y, 150, 45)
        blurEffectView.frame = blurEffectView_Frame
        blurEffectView.alpha = 0.75
        blurEffectView.layer.cornerRadius = 3
        blurEffectView.userInteractionEnabled = false
        btn_NextStep.addSubview(blurEffectView)
        btn_NextStep.sendSubviewToBack(blurEffectView)
        btn_NextStep.layer.cornerRadius = 3
        btn_NextStep.clipsToBounds = true
        
    }
    
    @IBAction func btn_NextStepClicked(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            switch self.currentStep {
            case 0:
                self.animateDescription(self.str_SecondStep)
                self.animateIcons()
                
                self.currentStep++
                
            case 1:
                self.animateDescription(self.str_ThirdStep)
                self.animateIcons()
                
                self.currentStep++
                if !self.iPhone6andLater {
                    self.btn_NextStep.setTitle("Finish", forState: .Normal)
                }
                
            case 2:
                if self.iPhone6andLater {
                    self.animateDescription(self.str_FourthStep)
                    self.animateIcons()
                    
                    self.currentStep++
                    self.btn_NextStep.setTitle("Finish", forState: .Normal)
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
    
    func animateDescription(string: String) {
        
        UIView.animateWithDuration(0.4, animations: {
            self.label_Description.alpha = 0.0
            }) { (complete: Bool) -> Void in
                self.label_Description.text = string
                UIView.animateWithDuration(0.4, animations: {
                    self.label_Description.alpha = 0.6
                }, completion: nil)
        }
    }
    
    func animateIcons() {
        let img_QuickTime = UIImage(named: "img_QuickTime")
        let img_Tutorial4 = UIImage(named: "img_Tutorial4")
        if self.currentStep == 2 && self.iPhone6andLater {
            UIView.transitionWithView(self.img_Tutorial3, duration: 0.8, options: .TransitionCrossDissolve, animations: {
                self.img_Tutorial3.image = img_Tutorial4
                self.img_Tutorial3.alpha == 0.9
            }, completion: nil)
        } else {
            UIView.transitionWithView(self.img_OrientationLock,
                duration: 0.8,
                options: .TransitionCrossDissolve,
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
        println("USERDEFAULTS")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "tutorialSkipped")
        let cameraView = self.storyboard!.instantiateViewControllerWithIdentifier("CameraView") as! HC_MainViewController
        self.presentViewController(cameraView, animated: true, completion: nil)
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
