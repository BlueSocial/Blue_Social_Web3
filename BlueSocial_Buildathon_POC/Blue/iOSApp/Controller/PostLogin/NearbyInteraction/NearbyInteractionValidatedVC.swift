//
//  NearbyInteractionValidatedVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class NearbyInteractionValidatedVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewMyProfile: UIImageView!
    @IBOutlet weak var lblCurrentUserName: UILabel!
    
    @IBOutlet weak var imgViewNearbyUserProfile: UIImageView!
    @IBOutlet weak var lblNearbyUserName: UILabel!
    
    @IBOutlet weak var lblInteractionStatus: UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var nearbyUserDetail: UserDetail?
    var isSuccess = false
    var interactionDuration = 30
    var BSTValue = "0"
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isSuccess {
        } else {
            self.lblInteractionStatus.text = "Not Completed"
        }
        
        self.updateMyProfileUI()
        self.getNearbyUserProfileUI()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnContinue(_ sender: UIButton) {
        
        if self.isSuccess {
            
            let interactionBSTVC = InteractionBSTVC.instantiate(fromAppStoryboard: .NearbyInteraction)
            interactionBSTVC.BST = self.BSTValue
            interactionBSTVC.nearbyUserDetail = self.nearbyUserDetail
            self.navigationController?.pushViewController(interactionBSTVC, animated: true)
            
        } else {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
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
                    self.navigationController?.pushViewController(tabbar, animated: true)
                }
            }
        }
        
        self.notifyToBrodcastMyProfile()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func updateMyProfileUI() {
        
        if let loginIndex = arrAccount.lastIndex(where: { oneAccountData in
            return oneAccountData[APIParamKey.kUserId] as? String == UserLocalData.UserID
        }) {
            guard let profile = UserLocalData.arrOfAccountData[loginIndex][APIParamKey.kProfilePic] else { return }
            
            if let url = URL(string: profile as? String ?? "") {
                self.imgViewMyProfile.af_setImage(withURL: url, filter: nil)
            }
        }
    }
    
    private func getNearbyUserProfileUI() {
        
        if let nearbyUser = self.nearbyUserDetail {
            
            if let url = URL(string: nearbyUser.profile_img ?? "") {
                self.imgViewNearbyUserProfile.af_setImage(withURL: url, filter: nil)
            }
            
            self.lblNearbyUserName.text = "\(nearbyUser.firstname ?? "")"
            self.lblNearbyUserName.rotate(angle: 4)
        }
    }
}
