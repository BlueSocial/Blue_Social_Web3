//
//  ChooseRoleVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class ChooseRoleVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnPublic(_ sender: UIButton) {
        
        let publicRegisterVC = PublicRegisterVC.instantiate(fromAppStoryboard: .Login)
        self.navigationController?.pushViewController(publicRegisterVC, animated: true)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    
}
