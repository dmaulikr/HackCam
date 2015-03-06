//
//  HC_WelcomeView.swift
//  HackCam
//
//  Created by Clarence Ji on 3/5/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit

class HC_WelcomeView: UIViewController {

    @IBOutlet var img_Background: UIImageView!
    @IBOutlet var label_Welcometo: UILabel!
    @IBOutlet var label_Title: UILabel!
    @IBOutlet var btn_Start: UIButton!
    
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
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Button Style
        btn_Start.backgroundColor = UIColor(red: 0, green: 192/255, blue: 209/255, alpha: 0.20)
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = btn_Start.bounds
        blurEffectView.alpha = 0.75
        blurEffectView.layer.cornerRadius = 3
        blurEffectView.userInteractionEnabled = false
        btn_Start.addSubview(blurEffectView)
        btn_Start.sendSubviewToBack(blurEffectView)
        btn_Start.layer.cornerRadius = 3
        btn_Start.clipsToBounds = true
        
        
        // Prepare positions
        label_Welcometo.alpha = 0
        label_Title.alpha = 0
        label_Welcometo.center = CGPointMake(label_Welcometo.center.x, label_Welcometo.center.y + 20)
        label_Title.center = CGPointMake(label_Title.center.x, label_Title.center.y + 20)
        
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: nil, animations: { () -> Void in
            self.label_Welcometo.alpha = 0.6
            self.label_Welcometo.center = CGPointMake(self.label_Welcometo.center.x, self.label_Welcometo.center.y - 20)
            UIView.animateWithDuration(0.8, delay: 0.4, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: nil, animations: { () -> Void in
                self.label_Title.alpha = 1
                self.label_Title.center = CGPointMake(self.label_Title.center.x, self.label_Title.center.y - 20)
                }, completion: nil)
        }, completion: nil)
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func btn_Start_Pressed(sender: AnyObject) {
        println("Ow")
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
