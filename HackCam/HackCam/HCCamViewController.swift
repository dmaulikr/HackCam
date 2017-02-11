//
//  HCCamViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 2/10/17.
//  Copyright © 2017 Clarence Ji. All rights reserved.
//

import UIKit
import AVFoundation

class HCCamViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var camView: UIView!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var logoImgViewBottomConstr: NSLayoutConstraint!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    // Camera
    let captureSession = AVCaptureSession()
    var camera: AVCaptureDevice?
    var sessionOutput = AVCaptureVideoDataOutput()
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecH264])
    let photoOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.shared.isStatusBarHidden = true
        self.initCam()
        
        // Listen to orientation change
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Logo Image View Style
        self.logoImgView.layer.shadowColor = UIColor.black.cgColor
        self.logoImgView.layer.shadowOffset = CGSize.zero
        self.logoImgView.layer.shadowOpacity = 1
        self.logoImgView.layer.shadowRadius = 3.0
        self.logoImgView.clipsToBounds = false
        
        // Logo Image with Gesture Recognizer
        self.logoImgView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(smallLogoTapped))
        self.logoImgView.addGestureRecognizer(gestureRecognizer)
        
        // Initially hide the visual effect view and big logo
        self.visualEffectView.alpha = 0
        self.visualEffectView.isHidden = true
        
        // Visual Effect View with Gesture Recognizer
        self.visualEffectView.isUserInteractionEnabled = true
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(visualEffectViewTapped))
        self.visualEffectView.addGestureRecognizer(gestureRecognizer2)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession.startRunning()
        // Disable Screen Lock
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Enable Screen Lock
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        previewLayer.frame = camView.bounds
        
    }
    
    /// In case the device is rotated
    @objc private func deviceRotated() {
        
        let previewLayerConnection = self.previewLayer.connection
        guard previewLayerConnection != nil else { return }
        
        let currentOrientation = UIApplication.shared.statusBarOrientation.rawValue
        
        if previewLayerConnection!.isVideoOrientationSupported {
            previewLayerConnection!.videoOrientation = AVCaptureVideoOrientation(rawValue: currentOrientation)!
        }
        
        self.logoImgViewBottomConstr.constant = (currentOrientation == 3 || currentOrientation == 4) ? 8 : 20
        
    }
    
    @objc private func smallLogoTapped() {
        
        DispatchQueue.main.async {
            self.visualEffectView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.6) {
            self.logoImgView.alpha = 0
            self.visualEffectView.alpha = 1
        }
        
    }
    
    @objc private func visualEffectViewTapped() {
        
        UIView.animate(withDuration: 0.6, animations: { 
            self.logoImgView.alpha = 1
            self.visualEffectView.alpha = 0
        }) { (_) in
            self.visualEffectView.isHidden = true
        }
        
    }

    /// Initialize Camera
    private func initCam() {
        
        let devices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDuoCamera, .builtInTelephotoCamera], mediaType: AVMediaTypeVideo, position: .unspecified).devices
        
        for device in devices! {
            
            if device.position == .back && device.deviceType == .builtInWideAngleCamera {
                
                self.camera = device
                
                do {
                    
                    var finalFormat: AVCaptureDeviceFormat!
                    for vFormat in device.formats {
                        var ranges = (vFormat as AnyObject).videoSupportedFrameRateRanges as![AVFrameRateRange]
                        let frameRates = ranges[0]
                        if frameRates.maxFrameRate == 60 {
                            finalFormat = vFormat as! AVCaptureDeviceFormat
                        }
                    }
                    
                    let input = try AVCaptureDeviceInput(device: device)
                    if captureSession.canAddInput(input) {
                        
                        captureSession.addInput(input)
                        
                        try device.lockForConfiguration()
                        device.activeFormat = finalFormat
                        device.activeVideoMinFrameDuration = CMTimeMake(1, 60)
                        device.activeVideoMaxFrameDuration = CMTimeMake(1, 60)
                        device.unlockForConfiguration()
                        
                        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                        camView.layer.addSublayer(previewLayer)
                        
                    }
                    
                } catch{
                    print("exception!")
                }
                
            }
            
        }
        
    }

}
