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
        
        // Navigation Controller
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = .white
        }

        // Panorama Background View
        let panoramaView = PanoramaView(frame: self.view.bounds)
        panoramaView.setImage(#imageLiteral(resourceName: "background"))
        panoramaView.setScrollIndicatorEnabled(false)
        self.navigationController?.view.insertSubview(panoramaView, at: 0)
        
        // Button Skip
        getStartedButton.layer.cornerRadius = 3
        getStartedButton.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .regular)
        let buttonBlurView = UIVisualEffectView(frame: getStartedButton.bounds)
        buttonBlurView.effect = blurEffect
        buttonBlurView.layer.cornerRadius = 3
        buttonBlurView.clipsToBounds = true
        buttonBlurView.isUserInteractionEnabled = false
        
        getStartedButton.insertSubview(buttonBlurView, at: 0)
        
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
