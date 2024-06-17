//
//  LogoutVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class LogoutVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewBlur: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blueViewTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.viewBlur.addGestureRecognizer(blueViewTap)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnCancel(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnLogout(_ sender: UIButton) {
        
        self.logoutCurrentUser()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        self.dismiss(animated: true)
    }
}

extension LogoutVC {
    
    private func logoutCurrentUser() {
        
        let url = BaseURL + APIName.kLogout
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kLogout]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                
                BLEManager.shared.stopScanning()
                BLEPeripherals.shared.stopAdvertise()
                loginUser = nil
                
                self.setQRCodeURLForWidget()
                
                if self.checkAndRemoveCurrentUserData(userID: UserLocalData.UserID) {
                    
                    if let loginIndex = arrAccount.lastIndex(where: { $0[APIParamKey.kUserId] as? String == UserLocalData.UserID }) {
                        arrAccount.remove(at: loginIndex)
                        UserLocalData.arrOfAccountData = arrAccount
                    }
                    
                    UserLocalData.breakTheICE = false
                    BLEManager.shared.isBlePermissionGivenInTour = false
                    
                    if !arrAccount.isEmpty {
                        
                        let lastAccountData = arrAccount.last!
                        UserLocalData.UserID = lastAccountData[APIParamKey.kUserId] as! String
                        
                        self.loginAccount(email: lastAccountData[APIParamKey.kEmail] as! String, password: lastAccountData[APIParamKey.kPassword] as! String, switchUserID: lastAccountData[APIParamKey.kUserId] as! String)
                        
                        UserLocalData.clearAllUserData()
                        
                    } else {
                        
                        self.dismiss(animated: true)
                        self.hideCustomLoader()
                        
                        let chooseRoleVC = ChooseRoleVC.instantiate(fromAppStoryboard: .Login)
                        let navigationController = UINavigationController(rootViewController: chooseRoleVC)
                        navigationController.setNavigationBarHidden(true, animated: true)
                        
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window {
                            window.rootViewController = navigationController
                            window.makeKeyAndVisible()
                        }
                    }
                    
                    UserLocalData.UserID = ""
                }
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    func loginAccount(email: String, password: String, switchUserID: String) {
        
        let url = BaseURL + APIName.kLogin
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kLogin,
                                    APIParamKey.kEmail: email,
                                    APIParamKey.kPassword: password,
                                    APIParamKey.kPushToken: pushNotificationToken,
                                    APIParamKey.kDeviceType: APIFlagValue.kiPhone]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                
                guard let userData = response?.userDetail else { return }
                UserLocalData.UserID = userData.id ?? ""
                
                self.callGetInfoAPI(UserID: UserLocalData.UserID) { isSuccess, responce in
                    
                    if isSuccess {
                        
                        self.dismiss(animated: true)
                        
                        let tabbar = MainTabbarController.instantiate(fromAppStoryboard: .Discover)
                        tabbar.selectedIndex = 1 // Select the desired tab index
                        
                        let navigationController = UINavigationController(rootViewController: tabbar)
                        navigationController.setNavigationBarHidden(true, animated: true)
                        
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window {
                            window.rootViewController = navigationController
                            window.makeKeyAndVisible()
                        }
                        
                    } else {
                        
                        self.hideCustomLoader()
                        
                        if self.checkAndRemoveCurrentUserData(userID: switchUserID) {
                            
                        }
                    }
                }
                
            } else {
                
                self.hideCustomLoader()
            }
        }
    }
}
