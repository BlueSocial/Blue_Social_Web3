//
//  NearbyUserIncompleteProfileVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class NearbyUserIncompleteProfileVC: BaseVC {

    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var nearByUserId = ""
    var onDismiss: ((UserDetail) -> Void)?
    private var userDetail: UserDetail?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        print("NearBy user id: \(self.nearByUserId)")
        self.foundNearByUserInfo()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnOk(_ sender: UIButton) {
        
        if let userInfo = self.userDetail {
            onDismiss?(userInfo)
        }
        self.dismiss(animated: true)
    }
    
    private func foundNearByUserInfo() {
        
        self.callGetInfoAPI(UserID: self.nearByUserId) { isSuccess, response in
            
            if let getInfoAPIResponse = response {
                
                self.userDetail = getInfoAPIResponse
            }
        }
    }
}
