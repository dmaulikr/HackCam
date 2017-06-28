//
//  HCMainNavViewController.swift
//  HackCam
//
//  Created by Clarence Ji on 2/13/17.
//  Copyright © 2017 Clarence Ji. All rights reserved.
//

import UIKit

class HCMainNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.all
    }

}
