//
//  ViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 2/26/15.
//  Copyright (c) 2015 Clarence Ji. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

@available(iOS 8.0, *)
class HC_MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    fileprivate var cameraPicker = UIImagePickerController()
    fileprivate var currentOrientation: String = ""
    fileprivate var currentOrientation_Indicator: Bool = true
    
    // MARK: - IBOutlets
    @IBOutlet var btn_Start: UIButton!
    @IBOutlet var btn_ChangeLogo: UIButton!
    @IBOutlet var img_BottomRightLogo: UIImageView!
    @IBOutlet var img_Background: UIImageView!
    @IBOutlet var label_Hint: UILabel!
    
    fileprivate var wormhole: MMWormhole!
    fileprivate let groupID = "group.a.HackCam.WatchKit"
    
    // MARK: - Bool validations
    fileprivate var isBlurModeOn = false
    fileprivate var isCameraSession = false
    
    // MARK: - Motion Effect Variables
    fileprivate var verticalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
    fileprivate var horizontalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
    fileprivate var motionEffectGroup: UIMotionEffectGroup = UIMotionEffectGroup()
    
    // MARK: - View Controller Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerWatchNotification()
        
        if UIApplication.shared.statusBarOrientation == .portrait {
            currentOrientation = "Portrait"
        } else {
            currentOrientation = "LandscapeLeft"
        }
        
        // Create and share access to an NSUserDefaults object.
        let userDefaults = UserDefaults(suiteName: self.groupID)
        
        if let data: Data = userDefaults!.object(forKey: "storedLogoImage") as? Data {
            let newImage = UIImage(data: data)
            if newImage!.size.width / newImage!.size.height >= 1.8 {
                self.img_BottomRightLogo.frame = CGRect(x: self.img_BottomRightLogo.frame.origin.x - 50, y: self.img_BottomRightLogo.frame.origin.y, width: self.img_BottomRightLogo.frame.size.width + 50, height: self.img_BottomRightLogo.frame.height)
            }
            self.img_BottomRightLogo.image = UIImage(data: data)
        }
        
        let recog_Logo = UITapGestureRecognizer()
        recog_Logo.addTarget(self, action: #selector(HC_MainViewController.showBlurView(_:)))
        self.img_BottomRightLogo.addGestureRecognizer(recog_Logo)
        
        // Apply Parallax Effect
        applyParallaxEffect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HC_MainViewController.deviceOrientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Start button clicked
    @IBAction func btn_StartClicked(_ sender: AnyObject) {
        startCameraSession()
        
        self.btn_Start.isHidden = true
        self.btn_ChangeLogo.isHidden = true
        self.label_Hint.isHidden = true
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Blur View and Logo
    fileprivate var blurView: UIVisualEffectView!
    fileprivate var imageView_LogoBig: UIImageView!
    
    func showBlurView(_ recog: UIGestureRecognizer) {
        let blurEffect = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.alpha = 0
        
        let userDefaults = UserDefaults(suiteName: self.groupID)
        if let data: Data = userDefaults!.object(forKey: "storedLogoImage") as? Data {
            self.imageView_LogoBig = UIImageView(image: UIImage(data: data))
            self.imageView_LogoBig.contentMode = .scaleAspectFit
            self.imageView_LogoBig.frame = CGRect(x: 0, y: 0, width: 180, height: 180)
        } else {
            self.imageView_LogoBig = UIImageView(image: UIImage(named: "HL_Logo_Normal")!)
            self.imageView_LogoBig.frame = CGRect(x: 0, y: 0, width: 320, height: 180)
        }
        
        self.imageView_LogoBig.center = self.view.center
        self.imageView_LogoBig.alpha = 0
        self.imageView_LogoBig.layer.shadowColor = UIColor.black.cgColor
        self.imageView_LogoBig.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.imageView_LogoBig.layer.shadowOpacity = 1
        self.imageView_LogoBig.layer.shadowRadius = 3.0
        self.imageView_LogoBig.clipsToBounds = false
        
        self.view.addSubview(imageView_LogoBig)
        self.view.addSubview(blurView)
        self.view.bringSubview(toFront: blurView)
        self.view.bringSubview(toFront: imageView_LogoBig)
        self.view.bringSubview(toFront: recog.view!)
        
        UIView.animate(withDuration: 0.8, animations: {
            self.blurView.alpha = 1.0
            self.imageView_LogoBig.alpha = 1.0
            self.img_BottomRightLogo.alpha = 0.0
        })
        
        let recog_Dismiss = UITapGestureRecognizer()
        recog_Dismiss.addTarget(self, action: #selector(HC_MainViewController.dismissBlurView(_:)))
        blurView.addGestureRecognizer(recog_Dismiss)
        
        isBlurModeOn = true
     }
    
    func dismissBlurView(_ recog: UIGestureRecognizer) {
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 0.8, delay: 0, options: [], animations: {
                self.blurView.alpha = 0.0
                self.imageView_LogoBig.alpha = 0.0
                self.img_BottomRightLogo.alpha = 1.0
                }, completion: { (complete: Bool) -> Void in
                    self.blurView.removeFromSuperview()
                    self.imageView_LogoBig.removeFromSuperview()
                    self.blurView.removeGestureRecognizer(recog)
                    self.isBlurModeOn = false
            })
            
        })
        
    }
    
    // MARK: - App Lifecycle
    
    func applicationDidBecomeActive(_ notification: Notification) {
        print("start application listening")
        registerWatchNotification()
    }
    
    func applicationDidEnterBackground(_ notification: Notification) {
        print("stop listening for presentation?")
        if wormhole != nil {
            wormhole.stopListeningForMessage(withIdentifier: "blurMode")
        }
    }
    
    fileprivate func registerWatchNotification() {
        // Register notification with Apple Watch
        wormhole = MMWormhole(applicationGroupIdentifier: self.groupID, optionalDirectory: nil)
        wormhole.listenForMessage(withIdentifier: "blurMode", listener: { (messageObject) -> Void in
            if let message: AnyObject = messageObject as AnyObject? {
                let isPresent = message["value"] as! Bool
                if isPresent {
                    if !self.isBlurModeOn && self.img_BottomRightLogo != nil && self.isCameraSession {
                        self.showBlurView(self.img_BottomRightLogo.gestureRecognizers?.first as! UITapGestureRecognizer)
                    }
                } else {
                    if self.isBlurModeOn && self.blurView != nil && self.isCameraSession {
                        self.dismissBlurView(self.blurView.gestureRecognizers?.first as! UITapGestureRecognizer)
                    }
                }
            }
        })
    }
    
    // MARK: - Device Orientation
    func deviceOrientationChanged(_ notification: Notification) {
        let deviceOrientation = UIApplication.shared.statusBarOrientation
        switch deviceOrientation {
        case .landscapeLeft:
            DispatchQueue.main.async(execute: {
                self.cameraPicker.view.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 2))
                self.cameraPicker.view.frame = self.view.bounds
                if self.blurView != nil {
                    self.blurView!.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 2))
                    self.blurView!.frame = self.view.bounds
                    self.view.bringSubview(toFront: self.blurView!)
                    self.view.bringSubview(toFront: self.imageView_LogoBig!)
                }
                self.imageView_LogoBig?.center = self.view.center
                print("LandscapeLeft: \(self.cameraPicker.view.frame)")
            })
        case .portrait:
            DispatchQueue.main.async(execute: {
                self.cameraPicker.view.transform = CGAffineTransform(rotationAngle: CGFloat(2 * M_PI))
                self.cameraPicker.view.frame = self.view.bounds
                if self.blurView != nil {
                    self.blurView!.transform = CGAffineTransform(rotationAngle: CGFloat(2 * M_PI))
                    self.blurView!.frame = self.view.bounds
                    self.view.bringSubview(toFront: self.blurView!)
                    self.view.bringSubview(toFront: self.imageView_LogoBig!)
                }
                self.imageView_LogoBig?.center = self.view.center
                print("Portrait: \(self.cameraPicker.view.frame)")
            })
        default: break
        }
        
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
            
            DispatchQueue.main.async(execute: {
                
                self.img_BottomRightLogo.layer.shadowColor = UIColor.black.cgColor;
                self.img_BottomRightLogo.layer.shadowOffset = CGSize.zero;
                self.img_BottomRightLogo.layer.shadowOpacity = 1;
                self.img_BottomRightLogo.layer.shadowRadius = 3.0;
                self.img_BottomRightLogo.clipsToBounds = false;
                
                self.view.bringSubview(toFront: self.img_BottomRightLogo)
                
                self.isCameraSession = true
                
            })
            
            if UIApplication.shared.statusBarOrientation.hashValue == 3 {
                DispatchQueue.main.async(execute: {
                    self.cameraPicker.view.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 2))
                    self.cameraPicker.view.frame = self.view.bounds
                    print("LandscapeLeft: \(self.cameraPicker.view.frame)")
                })
            }
            
            
        } else {
            NSLog("Can't open camera.")
            
            // DEBUG
            self.isCameraSession = true
        }
        
        // Call notification
        self.wormhole.passMessageObject(["value":true] as NSCoding, identifier: "open")
        UserDefaults(suiteName: "group.a.HackCam.WatchKit")?.set(true, forKey: "open")
    }
    
    func startPhotoPickerSession() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let photoPicker = UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.allowsEditing = false
            photoPicker.sourceType = .savedPhotosAlbum
            
            self.present(photoPicker, animated: true, completion: nil)
            
        } else {
            NSLog("Cannot open library")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        let data = UIImagePNGRepresentation(image)
        let userDefaults = UserDefaults(suiteName: self.groupID)
        userDefaults!.set(data, forKey: "storedLogoImage")
        self.img_BottomRightLogo.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Change Logo
    // MARK: Button Clicked
    @IBAction func btn_ChangeLogoClicked(_ sender: AnyObject) {
        let chooseLogoSource = UIAlertController(title: nil, message: "Pick a 1:1 PNG image for the new logo. Recommended resolution: 640x640.", preferredStyle: .actionSheet)
        chooseLogoSource.addAction(UIAlertAction(title: "Enter URL", style: .default, handler: { (action) -> Void in
            // AlertView to enter url
            let urlAlertView = UIAlertController(title: nil, message: "Enter URL of your logo file:", preferredStyle: .alert)
            urlAlertView.addTextField(configurationHandler: { (textField: UITextField) -> Void in
                textField.text = "http://"
                textField.keyboardType = .URL
                textField.keyboardAppearance = UIKeyboardAppearance.dark
                textField.becomeFirstResponder()
            })
            urlAlertView.addAction(UIAlertAction(title: "Get Image", style: .default, handler: { (aa: UIAlertAction) -> Void in
                let inputString = (urlAlertView.textFields![0] ).text
                self.getImageFromURL(inputString!) {
                    (result: Bool) in
                    if !result {
                        urlAlertView.message = "Something went wrong, please try again."
                        self.present(urlAlertView, animated: true, completion: nil)
                    }
                }
                
            }))
            urlAlertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(urlAlertView, animated: true, completion: nil)
        }))
        
        chooseLogoSource.addAction(UIAlertAction(title: "Choose from Photo Library", style: .default, handler: { (action) -> Void in
            self.startPhotoPickerSession()
        }))
        
        chooseLogoSource.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(chooseLogoSource, animated: true, completion: nil)
    }
    
    // MARK: URL
    func getImageFromURL(_ input_Url: String, completion: @escaping (_ success: Bool) -> Void) {
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loadingIndicator.center = self.view.center
        loadingIndicator.startAnimating()
        loadingIndicator.hidesWhenStopped = true
        self.view.addSubview(loadingIndicator)
        
        var image: UIImage?
        
        if let url = URL(string: input_Url) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 8.0)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { (response, data, error) in
                if error == nil {
                    image = UIImage(data: data!)
                    loadingIndicator.stopAnimating()
                    
                    let userDefaults = UserDefaults(suiteName: self.groupID)
                    userDefaults!.setValue(data, forKey: "storedLogoImage")
                    DispatchQueue.main.async(execute: {
                        self.img_BottomRightLogo.image = image
                    })
                    completion(true)
                } else {
                    loadingIndicator.stopAnimating()
                    completion(false)
                }
            })
            
        }
        
    }
    
    // MARK: - Parallax Effect
    // MARK: Apply Parallax Effect
    func applyParallaxEffect() {
        // Parallax Effect
        motionEffectGroup.motionEffects = [verticalMotionEffect, horizontalMotionEffect]
        verticalMotionEffect.minimumRelativeValue = -15
        verticalMotionEffect.maximumRelativeValue = 15
        horizontalMotionEffect.minimumRelativeValue = -15
        horizontalMotionEffect.maximumRelativeValue = 15
        img_Background.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        img_Background.motionEffects = [motionEffectGroup]
    }
    // MARK: Remove Parallax Effect
    func removeParallaxEffect() {
        img_Background.transform = CGAffineTransform(scaleX: 1, y: 1)
        img_Background.motionEffects = []
    }
}

