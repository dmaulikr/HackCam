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
    
    private var cameraPicker = UIImagePickerController()
    private var currentOrientation: String = ""
    private var currentOrientation_Indicator: Bool = true
    
    // MARK: - IBOutlets
    @IBOutlet var btn_Start: UIButton!
    @IBOutlet var btn_ChangeLogo: UIButton!
    @IBOutlet var img_BottomRightLogo: UIImageView!
    @IBOutlet var img_Background: UIImageView!
    @IBOutlet var label_Hint: UILabel!
    
    private var wormhole: MMWormhole!
    private let groupID = "group.a.HackCam.WatchKit"
    
    // MARK: - Bool validations
    private var isBlurModeOn = false
    private var isCameraSession = false
    
    // MARK: - Motion Effect Variables
    private var verticalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
    private var horizontalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
    private var motionEffectGroup: UIMotionEffectGroup = UIMotionEffectGroup()
    
    // MARK: - View Controller Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerWatchNotification()
        
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
            currentOrientation = "Portrait"
        } else {
            currentOrientation = "LandscapeLeft"
        }
        
        // Create and share access to an NSUserDefaults object.
        let userDefaults = NSUserDefaults(suiteName: self.groupID)
        
        if let data: NSData = userDefaults!.objectForKey("storedLogoImage") as? NSData {
            let newImage = UIImage(data: data)
            if newImage!.size.width / newImage!.size.height >= 1.8 {
                self.img_BottomRightLogo.frame = CGRectMake(self.img_BottomRightLogo.frame.origin.x - 50, self.img_BottomRightLogo.frame.origin.y, self.img_BottomRightLogo.frame.size.width + 50, self.img_BottomRightLogo.frame.height)
            }
            self.img_BottomRightLogo.image = UIImage(data: data)
        }
        
        let recog_Logo = UITapGestureRecognizer()
        recog_Logo.addTarget(self, action: "showBlurView:")
        self.img_BottomRightLogo.addGestureRecognizer(recog_Logo)
        
        // Apply Parallax Effect
        applyParallaxEffect()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
       
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Start button clicked
    @IBAction func btn_StartClicked(sender: AnyObject) {
        startCameraSession()
        
        self.btn_Start.hidden = true
        self.btn_ChangeLogo.hidden = true
        self.label_Hint.hidden = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Blur View and Logo
    private var blurView: UIVisualEffectView!
    private var imageView_LogoBig: UIImageView!
    
    func showBlurView(recog: UIGestureRecognizer) {
        let blurEffect = UIBlurEffect(style: .Light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.alpha = 0
        
        let userDefaults = NSUserDefaults(suiteName: self.groupID)
        if let data: NSData = userDefaults!.objectForKey("storedLogoImage") as? NSData {
            self.imageView_LogoBig = UIImageView(image: UIImage(data: data))
            self.imageView_LogoBig.contentMode = .ScaleAspectFit
            self.imageView_LogoBig.frame = CGRectMake(0, 0, 180, 180)
        } else {
            self.imageView_LogoBig = UIImageView(image: UIImage(named: "HL_Logo_Normal")!)
            self.imageView_LogoBig.frame = CGRectMake(0, 0, 320, 180)
        }
        
        self.imageView_LogoBig.center = self.view.center
        self.imageView_LogoBig.alpha = 0
        self.imageView_LogoBig.layer.shadowColor = UIColor.blackColor().CGColor
        self.imageView_LogoBig.layer.shadowOffset = CGSizeMake(2, 2)
        self.imageView_LogoBig.layer.shadowOpacity = 1
        self.imageView_LogoBig.layer.shadowRadius = 3.0
        self.imageView_LogoBig.clipsToBounds = false
        
        self.view.addSubview(imageView_LogoBig)
        self.view.addSubview(blurView)
        self.view.bringSubviewToFront(blurView)
        self.view.bringSubviewToFront(imageView_LogoBig)
        self.view.bringSubviewToFront(recog.view!)
        
        UIView.animateWithDuration(0.8, animations: {
            self.blurView.alpha = 1.0
            self.imageView_LogoBig.alpha = 1.0
            self.img_BottomRightLogo.alpha = 0.0
        })
        
        let recog_Dismiss = UITapGestureRecognizer()
        recog_Dismiss.addTarget(self, action: "dismissBlurView:")
        blurView.addGestureRecognizer(recog_Dismiss)
        
        isBlurModeOn = true
     }
    
    func dismissBlurView(recog: UIGestureRecognizer) {
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.8, delay: 0, options: [], animations: {
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
    
    func applicationDidBecomeActive(notification: NSNotification) {
        print("start application listening")
        registerWatchNotification()
    }
    
    func applicationDidEnterBackground(notification: NSNotification) {
        print("stop listening for presentation?")
        if wormhole != nil {
            wormhole.stopListeningForMessageWithIdentifier("blurMode")
        }
    }
    
    private func registerWatchNotification() {
        // Register notification with Apple Watch
        wormhole = MMWormhole(applicationGroupIdentifier: self.groupID, optionalDirectory: nil)
        wormhole.listenForMessageWithIdentifier("blurMode", listener: { (messageObject) -> Void in
            if let message: AnyObject = messageObject {
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
    func deviceOrientationChanged(notification: NSNotification) {
        let deviceOrientation = UIApplication.sharedApplication().statusBarOrientation
        switch deviceOrientation {
        case .LandscapeLeft:
            dispatch_async(dispatch_get_main_queue(), {
                self.cameraPicker.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
                self.cameraPicker.view.frame = self.view.bounds
                if self.blurView != nil {
                    self.blurView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
                    self.blurView!.frame = self.view.bounds
                    self.view.bringSubviewToFront(self.blurView!)
                    self.view.bringSubviewToFront(self.imageView_LogoBig!)
                }
                self.imageView_LogoBig?.center = self.view.center
                print("LandscapeLeft: \(self.cameraPicker.view.frame)")
            })
        case .Portrait:
            dispatch_async(dispatch_get_main_queue(), {
                self.cameraPicker.view.transform = CGAffineTransformMakeRotation(CGFloat(2 * M_PI))
                self.cameraPicker.view.frame = self.view.bounds
                if self.blurView != nil {
                    self.blurView!.transform = CGAffineTransformMakeRotation(CGFloat(2 * M_PI))
                    self.blurView!.frame = self.view.bounds
                    self.view.bringSubviewToFront(self.blurView!)
                    self.view.bringSubviewToFront(self.imageView_LogoBig!)
                }
                self.imageView_LogoBig?.center = self.view.center
                print("Portrait: \(self.cameraPicker.view.frame)")
            })
        default: break
        }
        
    }
    
    
    
    // MARK: - Photo Picker / Camera Session
    func startCameraSession() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = false
            cameraPicker.mediaTypes = [String(kUTTypeMovie), String(kUTTypeImage)]
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
                
                self.img_BottomRightLogo.layer.shadowColor = UIColor.blackColor().CGColor;
                self.img_BottomRightLogo.layer.shadowOffset = CGSizeZero;
                self.img_BottomRightLogo.layer.shadowOpacity = 1;
                self.img_BottomRightLogo.layer.shadowRadius = 3.0;
                self.img_BottomRightLogo.clipsToBounds = false;
                
                self.view.bringSubviewToFront(self.img_BottomRightLogo)
                
                self.isCameraSession = true
                
            })
            
            if UIApplication.sharedApplication().statusBarOrientation.hashValue == 3 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.cameraPicker.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
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
        self.wormhole.passMessageObject(["value":true], identifier: "open")
        NSUserDefaults(suiteName: "group.a.HackCam.WatchKit")?.setBool(true, forKey: "open")
    }
    
    func startPhotoPickerSession() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let photoPicker = UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.allowsEditing = false
            photoPicker.sourceType = .SavedPhotosAlbum
            
            self.presentViewController(photoPicker, animated: true, completion: nil)
            
        } else {
            NSLog("Cannot open library")
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let data = UIImagePNGRepresentation(image)
        let userDefaults = NSUserDefaults(suiteName: self.groupID)
        userDefaults!.setObject(data, forKey: "storedLogoImage")
        self.img_BottomRightLogo.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Change Logo
    // MARK: Button Clicked
    @IBAction func btn_ChangeLogoClicked(sender: AnyObject) {
        let chooseLogoSource = UIAlertController(title: nil, message: "Pick a 1:1 PNG image for the new logo. Recommended resolution: 640x640.", preferredStyle: .ActionSheet)
        chooseLogoSource.addAction(UIAlertAction(title: "Enter URL", style: .Default, handler: { (action) -> Void in
            // AlertView to enter url
            let urlAlertView = UIAlertController(title: nil, message: "Enter URL of your logo file:", preferredStyle: .Alert)
            urlAlertView.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.text = "http://"
                textField.keyboardType = .URL
                textField.keyboardAppearance = UIKeyboardAppearance.Dark
                textField.becomeFirstResponder()
            })
            urlAlertView.addAction(UIAlertAction(title: "Get Image", style: .Default, handler: { (aa: UIAlertAction) -> Void in
                let inputString = (urlAlertView.textFields![0] ).text
                self.getImageFromURL(inputString!) {
                    (result: Bool) in
                    if !result {
                        urlAlertView.message = "Something went wrong, please try again."
                        self.presentViewController(urlAlertView, animated: true, completion: nil)
                    }
                }
                
            }))
            urlAlertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(urlAlertView, animated: true, completion: nil)
        }))
        
        chooseLogoSource.addAction(UIAlertAction(title: "Choose from Photo Library", style: .Default, handler: { (action) -> Void in
            self.startPhotoPickerSession()
        }))
        
        chooseLogoSource.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(chooseLogoSource, animated: true, completion: nil)
    }
    
    // MARK: URL
    func getImageFromURL(input_Url: String, completion: (success: Bool) -> Void) {
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        loadingIndicator.center = self.view.center
        loadingIndicator.startAnimating()
        loadingIndicator.hidesWhenStopped = true
        self.view.addSubview(loadingIndicator)
        
        var image: UIImage?
        
        if let url = NSURL(string: input_Url) {
            let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 8.0)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    image = UIImage(data: data!)
                    loadingIndicator.stopAnimating()
                    
                    let userDefaults = NSUserDefaults(suiteName: self.groupID)
                    userDefaults!.setValue(data, forKey: "storedLogoImage")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.img_BottomRightLogo.image = image
                    })
                    completion(success: true)
                } else {
                    loadingIndicator.stopAnimating()
                    completion(success: false)
                }
                
            }
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
        img_Background.transform = CGAffineTransformMakeScale(1.05, 1.05)
        img_Background.motionEffects = [motionEffectGroup]
    }
    // MARK: Remove Parallax Effect
    func removeParallaxEffect() {
        img_Background.transform = CGAffineTransformMakeScale(1, 1)
        img_Background.motionEffects = []
    }
}

