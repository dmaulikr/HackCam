//
//  ViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 11/27/16.
//  Copyright © 2016 Clarence Ji. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cameraPicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.async {
            self.startCameraSession()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Photo Picker / Camera Session
    func startCameraSession() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = false
            cameraPicker.mediaTypes = [String(kUTTypeMovie), String(kUTTypeImage)]
            cameraPicker.sourceType = .camera
            
            cameraPicker.cameraCaptureMode = .video
            cameraPicker.showsCameraControls = false
            cameraPicker.cameraDevice = .rear
            cameraPicker.cameraFlashMode = .off
            
            cameraPicker.videoQuality = UIImagePickerControllerQualityType.typeHigh
            
            cameraPicker.view.center = self.view.center
            cameraPicker.view.frame = self.view.bounds
            
            self.view.addSubview(cameraPicker.view)
            
            
        } else {
            NSLog("Can't open camera.")
        }
        
    }


}

