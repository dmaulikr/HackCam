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
        self.initCam()
        
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
