//
//  HCTutorialViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 2/12/17.
//  Copyright © 2017 Clarence Ji. All rights reserved.
//

import UIKit

class HCTutorialViewController: UIViewController {

    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.navigationController?.isNavigationBarHidden = true
        
        // Panorama Background View
        let panoramaView = PanoramaView(frame: self.view.bounds)
        panoramaView.setImage(#imageLiteral(resourceName: "background"))
        panoramaView.setScrollIndicatorEnabled(false)
        self.navigationController?.view.insertSubview(panoramaView, at: 0)
        
        // Button Skip
        getStartedButton.layer.cornerRadius = 6
        getStartedButton.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: getStartedButton.bounds.height)
        let buttonBlurView = UIVisualEffectView(frame: blurFrame)
        buttonBlurView.effect = blurEffect
        buttonBlurView.layer.cornerRadius = 6
        buttonBlurView.clipsToBounds = true
        buttonBlurView.isUserInteractionEnabled = false
        
        getStartedButton.insertSubview(buttonBlurView, at: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.6, animations: {
            self.view.frame.origin.x -= UIScreen.main.bounds.width
        }) { (_) in
            self.performSegue(withIdentifier: "HCTutorial0To1", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "HCTutorialSkip" {
            UserDefaults.standard.set(true, forKey: "HCTutorialSkipped")
        }
        
    }

}
