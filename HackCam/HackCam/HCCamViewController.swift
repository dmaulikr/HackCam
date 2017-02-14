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
    @IBOutlet weak var bigLogoImageView: UIImageView!
    @IBOutlet weak var previewInteractionVEView: UIVisualEffectView!
    @IBOutlet weak var forceTouchPrompt: UILabel!
    @IBOutlet weak var newUserPrompt: UILabel!
    
    // Camera
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var camera: AVCaptureDevice?
    fileprivate var sessionOutput = AVCaptureVideoDataOutput()
    fileprivate var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecH264])
    fileprivate let photoOutput = AVCapturePhotoOutput()
    fileprivate var previewLayer = AVCaptureVideoPreviewLayer()

    fileprivate var previewInteraction: UIPreviewInteraction!
    
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
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(smallLogoLongPressed(sender:)))
        longPressGestureRecognizer.minimumPressDuration = 3
        self.logoImgView.addGestureRecognizer(longPressGestureRecognizer)
        
        // Preview Blur Layer Gesture Recognizer
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(previewInteractionVETapped))
        self.previewInteractionVEView.addGestureRecognizer(gestureRecognizer1)
        
        // Initially hide the visual effect view and big logo
        self.visualEffectView.alpha = 0
        self.visualEffectView.isHidden = true
        
        // Visual Effect View with Gesture Recognizer
        self.visualEffectView.isUserInteractionEnabled = true
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(visualEffectViewTapped))
        self.visualEffectView.addGestureRecognizer(gestureRecognizer2)
        
        // Hide back button
        self.navigationItem.hidesBackButton = true
        
        // Set Logo
        if let data: Data = UserDefaults.standard.object(forKey: "storedLogoImage") as? Data {
            let image = UIImage(data: data)
            self.logoImgView.image = image
            self.bigLogoImageView.image = image
        }
        
        // UIPreviewInteraction (3D Touch)
        self.previewInteraction = UIPreviewInteraction(view: self.view)
        self.previewInteraction.delegate = self
        self.forceTouchPrompt.layer.cornerRadius = 5
        self.forceTouchPrompt.clipsToBounds = true
        
        // If first time, show prompt
        if UserDefaults.standard.bool(forKey: "HCNewUserPromptSeen") != true {
            self.newUserPrompt.alpha = 1
            self.newUserPrompt.layer.cornerRadius = 6
            self.newUserPrompt.clipsToBounds = true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
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
    
    @objc private func smallLogoLongPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        } else {
            return
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
    
    @objc private func previewInteractionVETapped() {
        
        UIView.animate(withDuration: 0.3) { 
            self.previewInteractionVEView.alpha = 0
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

    @IBAction func promptTextTapped(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.4, animations: { 
            self.newUserPrompt.alpha = 0
        }) { (_) in
            self.newUserPrompt.isHidden = true
            UserDefaults.standard.set(true, forKey: "HCNewUserPromptSeen")
        }
        
    }
    
}

extension HCCamViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

extension HCCamViewController: UIPreviewInteractionDelegate {
    
    func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {
        
        UIView.animate(withDuration: 0.2) { 
            self.previewInteractionVEView.alpha = transitionProgress
        }
        
    }
    
    func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdateCommitTransition transitionProgress: CGFloat, ended: Bool) {
        
        if ended {
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func previewInteractionDidCancel(_ previewInteraction: UIPreviewInteraction) {
        
        UIView.animate(withDuration: 0.3) { 
            self.previewInteractionVEView.alpha = 0
        }
        
    }
    
}
