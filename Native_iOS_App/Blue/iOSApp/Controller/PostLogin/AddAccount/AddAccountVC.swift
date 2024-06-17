//
//  AddAccountVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import AlamofireImage

class AddAccountVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var tblAccountList: UITableView!
    @IBOutlet weak var viewBlur: UIView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTapGesture()
        self.getMultipleUserAccount()
        self.tblAccountList.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UserLocalData.arrOfAccountData = arrAccount
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------
extension AddAccountVC {
    
    private func setupTapGesture() {
        
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blurViewTap)
    }
    
    @objc func blurViewTap(_ sender: UITapGestureRecognizer? = nil) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onBtnAddAccount(sender: UIButton) {
        
        if arrAccount.count < 4 {
            
            self.dismiss(animated: true) {
                
                if let topVC = UIApplication.getTopViewController() {
                    
                    let publicLoginVC = PublicLoginVC.instantiate(fromAppStoryboard: .Login)
                    topVC.navigationController?.pushViewController(publicLoginVC, animated: true)
                }
            }
            
        } else {
            self.showAlertWithOKButton(message: kALERT_MaxAccount)
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension AddAccountVC {
    
    private func callLogoutAPI(switchEmail: String, switchPassword: String) {
        
        let url = BaseURL + APIName.kLogout
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kLogout]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                self.callLoginAPI(email: switchEmail, password: switchPassword)
            }
        }
    }
    
    private func callLoginAPI(email: String, password: String) {
        
        let url = BaseURL + APIName.kLogin
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kLogin,
                                    APIParamKey.kEmail: email,
                                    APIParamKey.kPassword: password,
                                    APIParamKey.kPushToken: pushNotificationToken,
                                    APIParamKey.kDeviceType: APIFlagValue.kiPhone]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                guard let userData = response?.userDetail else { return }
                
                self.getLoginUserDataFromDB(userMode: userData.user_mode ?? "0") { isSuccess, responce in
                    
                    if isSuccess {
                        
                        if let profile = responce {
                            
                            UserLocalData.UserID = profile.id ?? ""
                            loginUser = profile
                            self.tblAccountList.reloadData()
                        }
                        
                    } else {
                        
                        self.showAlertWithOKButton(message: "Something going wrong with your profile", title: "Error", btnTitle: "Ok", { () in
                            
                            if let loginIndex = arrAccount.lastIndex(where: { oneAccountData in
                                
                                return oneAccountData[APIParamKey.kUserId] as? String == UserLocalData.UserID
                            }) {
                                arrAccount.remove(at: loginIndex)
                                UserLocalData.arrOfAccountData = arrAccount
                            }
                        })
                    }
                }
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}

// ----------------------------------------------------------
//                 MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension AddAccountVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrAccount.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if arrAccount.count > 0 {
            
            if indexPath.row == arrAccount.count {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddAccountTableViewCell") as! AddAccountTableViewCell
                cell.btnAddAccount.addTarget(self, action: #selector(self.onBtnAddAccount(sender:)), for: .touchUpInside)
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MutipleAccountTableViewCell") as! AddAccountTableViewCell
                cell.configureCell(accountInfo: arrAccount[indexPath.row])
                return cell
            }
            
        } else { return UITableViewCell() }
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView Delegate -
// ----------------------------------------------------------
extension AddAccountVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row != arrAccount.count && arrAccount.count > 1) && (loginUser?.email != (arrAccount[indexPath.row]["email"] as! String)) {
            
            if isInternetAvailable == false {
                self.showAlertWithOKButton(message: kPlease_connect_Internet)
                
            } else {
                
                self.showAlertWith2Buttons(title: kAppName, message: kSwitchAccount, btnOneName: kNo, btnTwoName: kYes) { (btn) in
                    
                    if btn == 2 {
                        
                        let data = arrAccount[indexPath.row]
                        UserLocalData.UserID = data[APIParamKey.kUserId] as! String
                        self.callLogoutAPI(switchEmail: data[APIParamKey.kEmail] as! String, switchPassword: data[APIParamKey.kPassword] as! String)
                    }
                }
            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - Function -
// ----------------------------------------------------------
extension AddAccountVC {
    
    
}
