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
    @IBOutlet var btn_Skip: UIButton!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Button Style
        btn_Start.backgroundColor = UIColor(red: 0, green: 192/255, blue: 209/255, alpha: 0.20)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let blurEffectView_Frame = CGRect(x: btn_Start.bounds.origin.x, y: btn_Start.bounds.origin.y, width: 150, height: 45)
        blurEffectView.frame = blurEffectView_Frame
        blurEffectView.alpha = 0.75
        blurEffectView.layer.cornerRadius = 3
        blurEffectView.isUserInteractionEnabled = false
        btn_Start.addSubview(blurEffectView)
        btn_Start.sendSubview(toBack: blurEffectView)
        btn_Start.layer.cornerRadius = 3
        btn_Start.clipsToBounds = true
        
        
        // Prepare positions
        label_Welcometo.alpha = 0
        label_Title.alpha = 0
        label_Welcometo.center = CGPoint(x: label_Welcometo.center.x, y: label_Welcometo.center.y + 20)
        label_Title.center = CGPoint(x: label_Title.center.x, y: label_Title.center.y + 20)
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
            self.label_Welcometo.alpha = 0.6
            self.label_Welcometo.center = CGPoint(x: self.label_Welcometo.center.x, y: self.label_Welcometo.center.y - 20)
            UIView.animate(withDuration: 0.8, delay: 0.4, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
                self.label_Title.alpha = 1
                self.label_Title.center = CGPoint(x: self.label_Title.center.x, y: self.label_Title.center.y - 20)
                }, completion: nil)
        }, completion: nil)
        
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func btn_Start_Pressed(_ sender: AnyObject) {
        print("Transiting")
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 0.5, animations: {
                self.btn_Start.alpha = 0
                self.btn_Skip.alpha  = 0
                UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                    self.label_Welcometo.center = CGPoint(x: self.label_Welcometo.center.x, y: self.label_Welcometo.center.y - 100)
                    self.label_Welcometo.alpha = 0
                    
                    UIView.animate(withDuration: 0.5, delay: 0.2, options: [], animations: {
                        self.label_Title.center = CGPoint(x: self.label_Title.center.x, y: self.label_Title.center.y - 100)
                        self.label_Title.alpha = 0
                        }, completion: {(Bool) -> Void in
                            let view_Tutorial1 = self.storyboard!.instantiateViewController(withIdentifier: "Tutorial1") as! HC_Tutorial1
                            self.present(view_Tutorial1, animated: false, completion: nil)
                    })
                }, completion: nil)
            }, completion: nil)
        })
    }
    
    @IBAction func btn_Skip_Pressed(_ sender: AnyObject) {
        wormhole.passMessageObject(["value":true] as NSCoding, identifier: "tutorial")
        
        finishTutorial()
        
        let mainView = self.storyboard!.instantiateViewController(withIdentifier: "CameraView") as! HC_MainViewController
        self.present(mainView, animated: true, completion: nil)
    }
    
    func finishTutorial() {
        UserDefaults(suiteName: self.groupID)?.set(true, forKey: "tutorialSkipped")
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
