//
//  HCMainNavViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 2/13/17.
//  Copyright © 2017 Clarence Ji. All rights reserved.
//

import UIKit

class HCMainNavViewController: UINavigationController {
    
    internal var navBarBackgroundImage: UIImage! = nil
    internal var navBarShadowImage: UIImage! = nil
    internal var isNavBarTranslucent = false
    internal var navBarTintColor: UIColor! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard visibleViewController != nil else { return .all }
        return visibleViewController!.supportedInterfaceOrientations
    }

}
