//
//  CameraView.swift
//  HackCam
//
//  Created by Clarence Ji on 3/4/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit
import AVFoundation

class HC_CameraView: UIViewController {
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    private var currentOrientation: String = ""
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
            currentOrientation = "Portrait"
        } else {
            currentOrientation = "LandscapeLeft"
        }
        
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
        
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill

        
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIApplication.sharedApplication().statusBarOrientation.rawValue)!
        
        
        dispatch_async(dispatch_get_main_queue(), {
            self.view.bounds = UIScreen.mainScreen().bounds
            if self.currentOrientation == "LandscapeLeft" {
                self.currentOrientation = "LandscapeLeft"
                println("Now LandscapeLeft, trnasformation prerformed")
                dispatch_async(dispatch_get_main_queue(), {
                    self.previewLayer?.frame = self.view.bounds
                    self.previewLayer?.videoGravity = AVLayerVideoGravityResize
                })
            }
            
        })
        
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
            if device.lockForConfiguration(nil) {
                
                let touch = touches.first as! UITouch
                let location = touch.locationInView(touch.window)
                var focus_x = location.x / screenWidth;
                var focus_y = location.y / screenHeight;
                
                device.focusPointOfInterest = location
                device.focusMode = .AutoFocus
                println(location)
                println(CGPointMake(focus_x, focus_y))
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
            device.focusMode = .ContinuousAutoFocus
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
        
        var deviceOrientation = UIApplication.sharedApplication().statusBarOrientation
        switch deviceOrientation {
        case .Portrait:
            self.previewLayer?.connection.videoOrientation = .Portrait
            dispatch_async(dispatch_get_main_queue(), {
                self.previewLayer?.frame = self.view.bounds
                self.previewLayer?.videoGravity = AVLayerVideoGravityResize
            })
        case .LandscapeLeft:
            self.previewLayer?.connection.videoOrientation = .LandscapeLeft
            dispatch_async(dispatch_get_main_queue(), {
                self.previewLayer?.frame = self.view.bounds
                self.previewLayer?.videoGravity = AVLayerVideoGravityResize
            })
        default: break
        }
    }

    
}