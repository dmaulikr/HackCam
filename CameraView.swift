//
//  CameraView.swift
//  HackCam
//
//  Created by Clarence Ji on 3/4/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIViewController {
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    private var currentOrientation: String = ""
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func focusTo(value : Float) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                    //
                })
                device.unlockForConfiguration()
            }
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.focusMode = .AutoFocus
                device.unlockForConfiguration()
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anyTouch = touches.first as! UITouch
        var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
        if self.currentOrientation == "LandscapeLeft" {
            touchPercent = anyTouch.locationInView(self.view).y / screenHeight
        }
        focusTo(Float(touchPercent))
    }
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .AutoFocus
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
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
                    self.view.transform =
                        CGAffineTransformTranslate(
                            CGAffineTransformMakeRotation(CGFloat(M_PI/2)), -15, -15)
                    //                        CGAffineTransformScale(
                    //                            CGAffineTransformTranslate(
                    //                                CGAffineTransformMakeRotation(CGFloat(M_PI/2)), -15, -15),
                    //                            1.2, 1.2)
                    self.view.frame = UIScreen.mainScreen().bounds
                })
            }
            
            
        case UIInterfaceOrientation.Portrait:
            println("Now Portrait")
            if self.currentOrientation != "Portrait" {
                self.currentOrientation = "Portrait"
                println("Now Portrait, transformation performed")
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.transform = CGAffineTransformTranslate(
                        CGAffineTransformMakeRotation(0), 0, 0)
                    //                        CGAffineTransformScale(
                    //                            CGAffineTransformTranslate(
                    //                                CGAffineTransformMakeRotation(0), 0, 0),
                    //                            1.2, 1.2)
                    
                    self.view.frame = UIScreen.mainScreen().bounds
                    
                    //                                    self.cameraPicker.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
                })
            }
            
        default:
            break
        }
        
        
    }

    
}