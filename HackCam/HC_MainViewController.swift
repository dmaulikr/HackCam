//
//  ViewController.swift
//  SimpleCamera
//
//  Created by Clarence Ji on 2/26/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class HC_MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    private var cameraPicker = UIImagePickerController()
    private var currentOrientation: String = ""
    private var currentOrientation_Indicator: Bool = true
    

    @IBOutlet var btn_ShowBlur: UIButton!
    @IBOutlet var img_BottomRightLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
            currentOrientation = "Portrait"
        } else {
            currentOrientation = "LandscapeLeft"
        }
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        }
    
    override func viewDidAppear(animated: Bool) {
//        self.presentViewController(CameraView(), animated: false, completion: nil)
    }
    
    @IBOutlet var btn_Start: UIButton!

    @IBAction func btn_StartClicked(sender: AnyObject) {
        startCameraSession()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startCameraSession() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = false
            cameraPicker.mediaTypes = [kUTTypeMovie, kUTTypeImage]
            cameraPicker.sourceType = .Camera
            
            cameraPicker.cameraCaptureMode = .Video
            cameraPicker.showsCameraControls = false
            cameraPicker.cameraDevice = .Rear
            cameraPicker.cameraFlashMode = .Off
            
            cameraPicker.videoQuality = UIImagePickerControllerQualityType.TypeHigh
            
            cameraPicker.view.center = self.view.center
            cameraPicker.view.frame = self.view.bounds
            
            self.view.addSubview(cameraPicker.view)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                let deviceWidth = UIScreen.mainScreen().bounds.width
                let deviceHeight = UIScreen.mainScreen().bounds.height
                
                
                
                self.img_BottomRightLogo.layer.shadowColor = UIColor.blackColor().CGColor;
                self.img_BottomRightLogo.layer.shadowOffset = CGSizeZero;
                self.img_BottomRightLogo.layer.shadowOpacity = 1;
                self.img_BottomRightLogo.layer.shadowRadius = 3.0;
                self.img_BottomRightLogo.clipsToBounds = false;
                
                var button = UIButton()
                button.setTitle("•", forState: .Normal)
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
                self.btn_ShowBlur.alpha = 0.6
                self.btn_ShowBlur.addTarget(self, action: "showBlurView:", forControlEvents: .TouchUpInside)
                
                
                
                self.view.addSubview(button)
                self.view.bringSubviewToFront(button)
                self.view.bringSubviewToFront(self.btn_ShowBlur)
                self.view.bringSubviewToFront(self.img_BottomRightLogo)
                
                
            })
            
            
        } else {
            println("Can't open camera.")
        }
    }
    
    var blurView: UIVisualEffectView!
    var imageView_LogoBig: UIImageView!
    
    func showBlurView(btn: UIButton) {
        println("I KNEW YOU WERE TROUBLE")
        let blurEffect = UIBlurEffect(style: .Light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.alpha = 0
        
        
        
        imageView_LogoBig = UIImageView(image: UIImage(named: "HL_Logo_Normal")!)
        imageView_LogoBig.frame = CGRectMake(0, 0, 320, 180)
        imageView_LogoBig.center = self.view.center
        imageView_LogoBig.alpha = 0
        imageView_LogoBig.layer.shadowColor = UIColor.blackColor().CGColor;
        imageView_LogoBig.layer.shadowOffset = CGSizeMake(2, 2);
        imageView_LogoBig.layer.shadowOpacity = 1;
        imageView_LogoBig.layer.shadowRadius = 3.0;
        imageView_LogoBig.clipsToBounds = false;
//        imageView_LogoBig.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
        
        self.view.addSubview(imageView_LogoBig)
        self.view.addSubview(blurView)
        self.view.bringSubviewToFront(blurView)
        self.view.bringSubviewToFront(imageView_LogoBig)
        self.view.bringSubviewToFront(btn)
        
        UIView.animateWithDuration(0.8, animations: {
            self.blurView.alpha = 1.0
            self.imageView_LogoBig.alpha = 1.0
        })
        
        btn.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        btn.addTarget(self, action: "dismissBlurView:", forControlEvents: .TouchUpInside)
    }
    
    func dismissBlurView(btn: UIButton) {
        println("SHAME ON ME NOW")
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.8, delay: 0, options: nil, animations: {
                self.blurView.alpha = 0.0
                self.imageView_LogoBig.alpha = 0.0
                }, completion: { (complete: Bool) -> Void in
                    self.blurView.removeFromSuperview()
                    self.imageView_LogoBig.removeFromSuperview()
            })
            
        })
        
        btn.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        btn.addTarget(self, action: "showBlurView:", forControlEvents: .TouchUpInside)
    }
    
    
    
    func deviceOrientationChanged(notification: NSNotification) {
        
        var deviceOrientation = UIApplication.sharedApplication().statusBarOrientation
        switch deviceOrientation {
        case .LandscapeLeft:
            dispatch_async(dispatch_get_main_queue(), {
                self.cameraPicker.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
                self.cameraPicker.view.frame = self.view.bounds
                println("LandscapeLeft: \(self.cameraPicker.view.frame)")
            })
        case .Portrait:
            dispatch_async(dispatch_get_main_queue(), {
                self.cameraPicker.view.transform = CGAffineTransformMakeRotation(CGFloat(2 * M_PI))
                self.cameraPicker.view.frame = self.view.bounds
                println("Portrait: \(self.cameraPicker.view.frame)")
            })
        default: break
        }
        
        
        
    }
}

