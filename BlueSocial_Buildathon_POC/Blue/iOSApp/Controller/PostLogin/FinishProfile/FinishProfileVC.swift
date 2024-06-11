//
//  FinishProfileVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class FinishProfileVC: BaseVC {
    
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
        
        let enteredUsername = UserLocalData.userName
          if !enteredUsername.isEmpty {
              loginUser?.username = enteredUsername
          }
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnIWillDoItLater(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnFinishNow(_ sender: UIButton) {
        print("Finish Now Tapped")
        
        self.dismiss(animated: true) {
            
            if let topVC = UIApplication.getTopViewController() {
                
                // Incomplete Profile
                if loginUser?.username == "" || loginUser?.username == nil {
                    
                    let addUserNameVC = AddUserNameVC.instantiate(fromAppStoryboard: .Login)
                    topVC.navigationController?.pushViewController(addUserNameVC, animated: true)
                    
                } else if loginUser?.profile_img == "" || loginUser?.profile_img == nil {
                    
                    let addPhotoVC = AddPhotoVC.instantiate(fromAppStoryboard: .Login)
                    topVC.navigationController?.pushViewController(addPhotoVC, animated: true)
                }
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    
}
