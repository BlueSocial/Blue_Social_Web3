//
//  MoreVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import SafariServices

class MoreVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var lblBSTBalance: UILabel!
    @IBOutlet weak var lblBSTInUSD: UILabel!
    @IBOutlet weak var imgProfile: CustomImage!
    @IBOutlet weak var imgIncompleteProfile: UIImageView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var businessFirstname = ""
    private var businessLastname = ""
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setProfileImage()
        
        if loginUser?.username == "" || loginUser?.username == nil || loginUser?.profile_img == "" || loginUser?.profile_img == nil { // Incomplete Profile
            
            //FinishProfileVC
            //Red Icon
            print("Profile is Incomplete")
            self.imgIncompleteProfile.isHidden = false
            
        } else { // Completed Profile
            
            print("Profile is Completed")
            self.imgIncompleteProfile.isHidden = true
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnWallet(_ sender: UIButton) {
        
        let walletVC = WalletVC.instantiate(fromAppStoryboard: .Discover)
        self.navigationController?.pushViewController(walletVC, animated: true)
    }
    
    @IBAction func onBtnMarketPlace(_ sender: UIButton) {
        
        if let url = URL(string: "https://blue.social/shop-blue/") {
            
            if UIApplication.shared.canOpenURL(url) {
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true, completion: nil)
                
            } else {
                // Handle the case where the URL cannot be opened
                // For example, show an error message to the user
            }
            
        } else {
            // Handle the case where the URL is not valid
            // For example, show an error message to the user
        }
    }
    
    @IBAction func onBtnSettings(_ sender: UIButton) {
        
        let settingsVC = SettingsVC.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func onBtnMyProfile(_ sender: UIButton) {
        
        if loginUser?.username == "" || loginUser?.username == nil || loginUser?.profile_img == "" || loginUser?.profile_img == nil { // Incomplete Profile
            
            let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
            finishProfileVC.modalTransitionStyle = .crossDissolve
            finishProfileVC.modalPresentationStyle = .overCurrentContext
            self.present(finishProfileVC, animated: true)
            
        } else { // Completed Profile
            
            let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            profileVC.navigationScreen = .currentUserProfile
            
            // Use a custom transition
            let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromTop
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            
            self.navigationController?.pushViewController(profileVC, animated: false)
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setProfileImage() {
        
        self.getLoginUserDataFromDB(userMode: UserLocalData.userMode) { isSuccess, userData in
            
            if isSuccess {
                
                DispatchQueue.main.async {
                    
                    if UserLocalData.userMode == "1" {
                        
                        self.lblBSTBalance.text = "\(userData?.totalBST ?? 0)"
                        
                        let BSTInUSD = self.returnTwoDigitAfterDecimal((Double(userData?.totalBST ?? 0) * 0.10))
                        self.lblBSTInUSD.text = "$\(BSTInUSD) USD"
                        
                        if userData?.business_profileURL != "" && userData?.business_profileURL != nil {
                            
                            if let url = URL(string: userData?.business_profileURL ?? "") {
                                self.imgProfile.af_setImage(withURL: url)
                            }
                            
                        } else {
                            
                            if let firstName = userData?.business_firstName?.capitalized.first {
                                self.businessFirstname = String(firstName)
                                
                            } else if let firstName = userData?.firstname?.capitalized.first {
                                self.businessFirstname = String(firstName)
                            }
                            
                            if let lastName = userData?.business_lastName?.capitalized.first {
                                self.businessLastname = String(lastName)
                                
                            } else if let lastName = userData?.lastname?.capitalized.first {
                                self.businessLastname = String(lastName)
                            }
                            
                            self.imgProfile.image = UIImage.imageWithInitial(initial: "\(self.businessFirstname)\(self.businessLastname)", imageSize: self.imgProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                        }
                        
                    } else {
                        
                        self.lblBSTBalance.text = "\(userData?.totalBST ?? 0)"
                        
                        let BSTInUSD = self.returnTwoDigitAfterDecimal((Double(userData?.totalBST ?? 0) * 0.10))
                        self.lblBSTInUSD.text = "$\(BSTInUSD) USD"
                        
                        if userData?.profile_img != "" && userData?.profile_img != nil {
                            
                            if let url = URL(string: userData?.profile_img ?? "") {
                                self.imgProfile.af_setImage(withURL: url)
                            }
                            
                        } else {
                            
                            self.imgProfile.image = UIImage.imageWithInitial(initial: "\(userData?.firstname?.capitalized.first ?? "A")\(userData?.lastname?.capitalized.first ?? "B")", imageSize: self.imgProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                        }
                    }
                }
            }
        }
    }
}
