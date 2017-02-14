//
//  HCTutorial1ViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 2/13/17.
//  Copyright © 2017 Clarence Ji. All rights reserved.
//

import UIKit

class HCTutorial1ViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Button Skip
        nextButton.layer.cornerRadius = 3
        nextButton.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .regular)
        let buttonBlurView = UIVisualEffectView(frame: nextButton.bounds)
        buttonBlurView.effect = blurEffect
        buttonBlurView.layer.cornerRadius = 3
        buttonBlurView.clipsToBounds = true
        buttonBlurView.isUserInteractionEnabled = false
        
        nextButton.insertSubview(buttonBlurView, at: 0)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.title = "Back"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Get Started"
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.6, animations: {
            self.view.frame.origin.x -= UIScreen.main.bounds.width
        }) { (_) in
            self.performSegue(withIdentifier: "HCTutorial1To2", sender: nil)
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
