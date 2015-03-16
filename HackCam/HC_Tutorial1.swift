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
        
        // Blur Effect
        var blurEffect: UIVisualEffect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        blurView.frame = self.view.bounds
        
        // Vibrancy Effect & view
        var vibrancyEffect = UIVibrancyEffect()
        var vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.setTranslatesAutoresizingMaskIntoConstraints(false)
        vibrancyView.frame = self.view.bounds
        vibrancyView.contentView.addSubview(img_OrientationLock)
        
        blurView.contentView.addSubview(vibrancyView)
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(img_Background)
    
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
