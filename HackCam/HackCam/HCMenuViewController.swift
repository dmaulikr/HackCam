//
//  HCMenuViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 2/13/17.
//  Copyright © 2017 Clarence Ji. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HCMenuViewController: UIViewController {
    
    @IBOutlet weak var currentLogo: UIImageView!
    @IBOutlet weak var gadBannerView: UIView!
    
    var panoramaView: PanoramaView!

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.isStatusBarHidden = false
        
        // Listen to orientation change
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Navigation Controller
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = .white
        }
        
        // Panorama Background View
        panoramaView = PanoramaView(frame: self.view.bounds)
        panoramaView.setImage(#imageLiteral(resourceName: "background"))
        panoramaView.setScrollIndicatorEnabled(false)
        self.navigationController?.view.insertSubview(panoramaView, at: 0)
        
        // Set Logo
        if let data: Data = UserDefaults.standard.object(forKey: "storedLogoImage") as? Data {
            self.currentLogo.image = UIImage(data: data)
        }
        
        // Set Skip Tutorial Flag to TRUE
        UserDefaults.standard.set(true, forKey: "HCTutorialSkipped")
        
        // GAD
        self.loadGAD()
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    /// In case the device is rotated
    @objc private func deviceRotated() {
        
        DispatchQueue.main.async {
            
            self.panoramaView.frame = self.view.bounds
            
        }
        
    }
    
    @IBAction func logoChangeTapped(sender: UIButton) {
        
        let chooseLogoSource = UIAlertController(title: nil, message: "Pick a 1:1 PNG image for the new logo. Recommended resolution: 640x640.", preferredStyle: .actionSheet)
        chooseLogoSource.addAction(UIAlertAction(title: "Enter URL", style: .default, handler: { (action) -> Void in
            
            // AlertView to enter url
            let urlAlertView = UIAlertController(title: nil, message: "Enter URL of your logo file (HTTPS):", preferredStyle: .alert)
            urlAlertView.addTextField(configurationHandler: { (textField: UITextField) -> Void in
                textField.text = "https://"
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
    
    private func loadGAD() {
    
        let gadBannerInnerView = GADBannerView(adSize: kGADAdSizeFullBanner)
        let screenWidth = UIScreen.main.bounds.width
        gadBannerInnerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth * 5 / 32)
        gadBannerInnerView.delegate = self
        gadBannerInnerView.adUnitID = "ca-app-pub-6290472779919436/7243547708"
        gadBannerInnerView.rootViewController = self
        
        gadBannerView.addSubview(gadBannerInnerView)
        
        let adRequest = GADRequest()
//        adRequest.testDevices = [kGADSimulatorID, "0d564139d594821a2a7a28d3c47f697f"]
        
        gadBannerInnerView.load(adRequest)
    
    }

}

extension HCMenuViewController {
    
    // MARK: URL
    fileprivate func getImageFromURL(_ input_Url: String, completion: @escaping (_ success: Bool) -> Void) {
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loadingIndicator.center = self.view.center
        loadingIndicator.startAnimating()
        loadingIndicator.hidesWhenStopped = true
        self.view.addSubview(loadingIndicator)
        
        var image: UIImage?
        
        if let url = URL(string: input_Url) {
            
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 8.0)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                guard error == nil else {
                    loadingIndicator.stopAnimating()
                    completion(false)
                    return
                }
                guard let data = data else {
                    loadingIndicator.stopAnimating()
                    completion(false)
                    return
                }
                
                image = UIImage(data: data)
                loadingIndicator.stopAnimating()
                
                UserDefaults.standard.setValue(data, forKey: "storedLogoImage")
                DispatchQueue.main.async(execute: {
                    self.currentLogo.image = image
                })
                completion(true)
                
            })
            
            task.resume()
            
        }
        
    }
    
}

extension HCMenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        UserDefaults.standard.setValue(data, forKey: "storedLogoImage")
        self.currentLogo.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension HCMenuViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.gadBannerView.alpha = 1
            })
            
        }
        
    }
    
}
