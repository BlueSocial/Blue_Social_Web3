//
//  DeleteVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class DeleteVC: BaseVC {
    
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
    
    @IBAction func onBtnDeleteAccount(_ sender: UIButton) {
        
        self.callLogoutUserAPI()
    }
    
    // ----------------------------------------------------------
    //                  MARK: - Function -
    // ----------------------------------------------------------
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true)
    }
    
    // ----------------------------------------------------------
    //                  MARK: - API Calling -
    // ----------------------------------------------------------
    private func callLogoutUserAPI() {
        
        let url = BaseURL + APIName.kLogout
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kLogout]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                self.callDeleteUserAccountAPI(userDeleteStatus: "1")
                
            } else {
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callDeleteUserAccountAPI(userDeleteStatus: String) {
        
        let url = BaseURL + APIName.kUpdateSettings
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kDelete,
                                    APIParamKey.kId: UserLocalData.UserID,
                                    APIParamKey.kIsDeleted: userDeleteStatus]
        
        let user_id_tobe_delete = UserLocalData.UserID
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            
            if isSucess {
                
                if self.checkAndRemoveCurrentUserData(userID: user_id_tobe_delete) {
                    
                    self.presentingViewController?.dismiss(animated: true) {
                        
                        self.checkUserHaveMoreAccount()
                    }
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callLoginAPI(email: String, pass: String, switchUserID: String) {
        
        let url = BaseURL + APIName.kLogin
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kLogin,
                                    APIParamKey.kEmail: email,
                                    APIParamKey.kPassword: pass,
                                    APIParamKey.kPushToken: pushNotificationToken,
                                    APIParamKey.kDeviceType: APIFlagValue.kiPhone]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                
                guard let userData = response?.userDetail else { return }
                UserLocalData.UserID = userData.id ?? ""
                
            } else {
                
                self.hideCustomLoader()
                
                if self.checkAndRemoveCurrentUserData(userID: switchUserID) {
                    self.setRootViewForChooseRoleVC()
                }
            }
        }
    }
    
    private func checkUserHaveMoreAccount() {
        
        if arrAccount.count > 0 {
            
            let data = arrAccount[0]
            self.callLoginAPI(email: data[APIParamKey.kEmail] as! String, pass: data[APIParamKey.kPassword] as! String, switchUserID: data[APIParamKey.kUserId] as! String)
            
        } else {
            
            self.setRootViewForChooseRoleVC()
        }
    }
    
    private func setRootViewForChooseRoleVC() {
        
        let chooseRoleVC = ChooseRoleVC.instantiate(fromAppStoryboard: .Login)
        
        let navigationController = UINavigationController(rootViewController: chooseRoleVC)
        navigationController.setNavigationBarHidden(true, animated: true)
        
        self.hideCustomLoader()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let window = appDelegate.window {
                // Now you have access to the window instance.
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }
    }
}
