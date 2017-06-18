//
//  HCTutorial3ViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 2/13/17.
//  Copyright © 2017 Clarence Ji. All rights reserved.
//

import UIKit

class HCTutorial3ViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mainText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Button Skip
        nextButton.layer.cornerRadius = 6
        nextButton.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: nextButton.bounds.height)
        let buttonBlurView = UIVisualEffectView(frame: blurFrame)
        buttonBlurView.effect = blurEffect
        buttonBlurView.layer.cornerRadius = 6
        buttonBlurView.clipsToBounds = true
        buttonBlurView.isUserInteractionEnabled = false
        
        nextButton.insertSubview(buttonBlurView, at: 0)
        
        mainText.layer.shadowOffset = CGSize.zero
        mainText.layer.shadowRadius = 8
        mainText.layer.shadowOpacity = 1
        mainText.layer.shadowColor = UIColor.black.cgColor

    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        DispatchQueue.main.async {
//            self.title = "Back"
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.title = "Step 3"
        }
    }

    @IBAction func nextTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.6, animations: {
            self.view.frame.origin.x -= UIScreen.main.bounds.width
        }) { (_) in
            self.performSegue(withIdentifier: "HCTutorial3ToFinish", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "HCTutorial3ToFinish" {
            UserDefaults.standard.set(true, forKey: "HCTutorialSkipped")
        }
        
    }

}
