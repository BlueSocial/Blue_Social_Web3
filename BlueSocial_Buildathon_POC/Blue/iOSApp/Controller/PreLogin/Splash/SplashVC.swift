//
//  SplashVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class SplashVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var mainView: CustomView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var currentTimeStamp = 0.0
    private var previousTimeStamp = 0.0
    private var timeInterval = 0.0
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setRootViewController()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
}
