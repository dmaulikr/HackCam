//
//  ViewController.swift
//  SimpleCamera
//
//  Created by Clarence Ji on 2/26/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    private var cameraPicker = UIImagePickerController()
    private var currentOrientation: String = ""
    private var currentOrientation_Indicator: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
            currentOrientation = "Portrait"
        } else {
            currentOrientation = "LandscapeLeft"
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    
    @IBOutlet var btn_Start: UIButton!

    @IBAction func btn_StartClicked(sender: AnyObject) {
        startCameraSession()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .LandscapeLeft
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
            
            cameraPicker.view.center = self.view.center
            
            
            self.view.addSubview(cameraPicker.view)
            
            
//            self.presentViewController(cameraPicker, animated: true, completion: {
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                    let deviceWidth = UIScreen.mainScreen().bounds.width
//                    let deviceHeight = UIScreen.mainScreen().bounds.height
//                    
//                    let imageView_Logo = UIImageView()
//                    
//                    imageView_Logo.image = UIImage(named: "HL_Logo")!
//                    imageView_Logo.frame = CGRectMake(deviceWidth - 80, -10, 70, 124)
//                    imageView_Logo.layer.shadowColor = UIColor.blackColor().CGColor;
//                    imageView_Logo.layer.shadowOffset = CGSizeMake(1, 1);
//                    imageView_Logo.layer.shadowOpacity = 1;
//                    imageView_Logo.layer.shadowRadius = 2.0;
//                    imageView_Logo.clipsToBounds = false;
//
//                    var button = UIButton()
//                    button.setTitle("•", forState: .Normal)
//                    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//                    
//                    button.frame = CGRectMake(deviceWidth - 50, deviceHeight - 30, 50, 30)
//                    button.addTarget(self, action: "button:", forControlEvents: .TouchUpInside)
//                    
//                    
//                    
//                    self.cameraPicker.view.addSubview(button)
//                    self.cameraPicker.view.addSubview(imageView_Logo)
//                })
//                
//            })
            
            
            
            
        } else {
            println("Can't open camera.")
        }
    }
    
    var blurView: UIVisualEffectView!
    var imageView_LogoBig: UIImageView!
    
    func button(btn: UIButton) {        
        println("I KNEW YOU WERE TROUBLE")
        let blurEffect = UIBlurEffect(style: .Light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.alpha = 0
        cameraPicker.view.addSubview(blurView)
        cameraPicker.view.bringSubviewToFront(btn)
        
        imageView_LogoBig = UIImageView(image: UIImage(named: "HL_Logo")!)
        imageView_LogoBig.frame = CGRectMake(0, 0, 180, 320)
        imageView_LogoBig.center = self.view.center
        imageView_LogoBig.alpha = 0
        imageView_LogoBig.layer.shadowColor = UIColor.blackColor().CGColor;
        imageView_LogoBig.layer.shadowOffset = CGSizeMake(2, 2);
        imageView_LogoBig.layer.shadowOpacity = 1;
        imageView_LogoBig.layer.shadowRadius = 3.0;
        imageView_LogoBig.clipsToBounds = false;
        cameraPicker.view.addSubview(imageView_LogoBig)
        
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
        btn.addTarget(self, action: "button:", forControlEvents: .TouchUpInside)
    }
    
    
    
    func deviceOrientationChanged(notification: NSNotification) {
        
        var currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        switch currentOrientation {
        case UIInterfaceOrientation.LandscapeLeft:
            println("Now LandscapeLeft")
            if self.currentOrientation != "LandscapeLeft" {
                self.currentOrientation = "LandscapeLeft"
                println("Now LandscapeLeft, trnasformation prerformed")
                dispatch_async(dispatch_get_main_queue(), {
                    self.cameraPicker.view.transform =
                        CGAffineTransformScale(
                            CGAffineTransformTranslate(
                                CGAffineTransformMakeRotation(CGFloat(M_PI/2)), -15, -15),
                            1.2, 1.2)
                    self.cameraPicker.view.frame = self.view.bounds
                })
            }
            
            
        case UIInterfaceOrientation.Portrait:
            println("Now Portrait")
            if self.currentOrientation != "Portrait" {
                self.currentOrientation = "Portrait"
                println("Now Portrait, transformation performed")
                dispatch_async(dispatch_get_main_queue(), {
                    self.cameraPicker.view.transform =
                        CGAffineTransformScale(
                            CGAffineTransformTranslate(
                                CGAffineTransformMakeRotation(0), 0, 0),
                            1.2, 1.2)
                    
                    self.cameraPicker.view.frame = self.view.bounds
                    
//                                    self.cameraPicker.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
                })
            }
            
        default:
            break
        }
        
        
    }
}

