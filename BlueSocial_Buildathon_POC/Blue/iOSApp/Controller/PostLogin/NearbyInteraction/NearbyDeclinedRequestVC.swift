//
//  NearbyDeclinedRequestVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class NearbyDeclinedRequestVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewNeabyUserProfile: UIImageView!
    @IBOutlet weak var nearbyUserName: UILabel!
    @IBOutlet weak var lblInteractionDetail: UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var nearbyUserDetail: UserDetail?
    var nearbyUserID: String?
    internal var isOpenFromSelfDeclined: Bool = false
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnClose(_ sender: UIButton) {

        var isVCFound = false
        for vc in self.navigationController?.viewControllers ?? [UIViewController]() {
            if vc is MainTabbarController {
                isVCFound = true
                self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
        if !isVCFound {
            
            let tabbar = MainTabbarController.instantiate(fromAppStoryboard: .Discover)
            
            UIApplication.shared.windows.first?.rootViewController = tabbar
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
            tabbar.selectedIndex = 1 // Discover | Dashboard
            
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        if let nearbyUser = self.nearbyUserDetail {
            
            if let url = URL(string: nearbyUser.profile_img ?? "") {
                self.imgViewNeabyUserProfile.af_setImage(withURL: url, filter: nil)
            }
            
            let firstname = "\(nearbyUser.firstname ?? "")"
            self.nearbyUserName.text = firstname
            
            if self.isOpenFromSelfDeclined {
                self.lblInteractionDetail.text = "You declined the Break The Ice request"
            } else {
                self.lblInteractionDetail.text = "\(firstname) is not available right now"
            }
            
        } else {
            
            let dbUserData = DBManager.checkUserSocialInfoExist(userID: self.nearbyUserID ?? "")
            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                self.nearbyUserDetail = dbUserModel
                self.setupUI()
                
            } else {
                
                self.showCustomLoader()
                self.callGetUserInfoAPI(nearByUserID: self.nearbyUserID ?? "") { isSuccess, response in
                    self.hideCustomLoader()
                    
                    if let getInfoAPIResponse = response {
                        
                        self.setUserSocialInfoInDB(userID: self.nearbyUserID ?? "", userJSON: getInfoAPIResponse.toJSONString()!)
                        
                        self.setupUI()
                    }
                }
            }
        }
    }
}
