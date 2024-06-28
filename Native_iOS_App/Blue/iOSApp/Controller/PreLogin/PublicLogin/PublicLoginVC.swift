//
//  PublicLoginVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import React

class PublicLoginVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblErrorEmail: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var viewEmail: CustomView!
    
    @IBOutlet weak var lblErrorPassword: UILabel!
    @IBOutlet weak var txtPassword: NoCopyPasteTextField!
    @IBOutlet weak var viewPassword: CustomView!
    @IBOutlet weak var btnEyeOPenClose: UIButton!
    
    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    @IBOutlet weak var lblSignup: UILabel!
    //@IBOutlet weak var btnMagicLink: UIButton!
    @IBOutlet weak var btnLogIn: UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var isErrorFoundInEmail: Bool = false
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.txtEmail.text = "mayur.bluepixel@gmail.com"
        // self.txtPassword.text = "Sure@123"
        
        // self.txtEmail.text = "rushi10@gmail.com"
        // self.txtPassword.text = "Sure@1234"
        
        // self.txtEmail.text = "hellojose@blue.social"
        // self.txtPassword.text = "NewWaytoNetwork"
        
        // self.txtEmail.text = "nikhiljobanputra@gmail.com"
        // self.txtPassword.text = "Sure@124"
        
        self.hideAllErrorLabels()
        self.setupPrivacyPolicyAttributes()
        self.setupSignUpAttributes()
        
        self.txtPassword.isSecureTextEntry = true
        self.btnEyeOPenClose.setImage(UIImage(named: "ic_eye_close"), for: .normal)
        
        self.btnLogIn.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnLogIn.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
        self.btnLogIn.isUserInteractionEnabled = false
        
        //self.txtEmail.addTarget(self, action: #selector(self.textFieldEmailDidChange(_:)), for: .editingChanged)
        
        // Add tap gesture recognizer to dismiss keyboard and hide border
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOutSideTextFieldArea))
        view.addGestureRecognizer(self.tapGestureRecognizer)
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldEditingChanged(_ senders: [UITextField]) {
        self.updateLogInButtonState()
    }
    
    @IBAction func onBtnEyeOPenClose(sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.txtPassword.isSecureTextEntry = false
            sender.setImage(UIImage(named: "ic_eye_open"), for: .normal)
            
        } else {
            self.txtPassword.isSecureTextEntry = true
            sender.setImage(UIImage(named: "ic_eye_close"), for: .normal)
        }
    }
    
    @IBAction func onBtnForgotPassword(_ sender: UIButton) {
        
        let forgetpasswordVC = PublicForgetPasswordVC.instantiate(fromAppStoryboard: .Login)
        self.navigationController?.pushViewController(forgetpasswordVC, animated: true)
    }
    
    @IBAction func onBtnLogIn(_ sender: UIButton) {
        print("Button Log In Tapped")
        
        if !(self.txtEmail.text ?? "").trime().isValidEmail() {
            self.lblErrorEmail.isHidden = false
            self.lblErrorEmail.text = alertInvalidEmail
            self.viewEmail.BordeHeight = 1
            self.viewEmail.BordeColor = UIColor.appRed_E13C3C()
            self.isErrorFoundInEmail = true
            
        } else {
            self.view.endEditing(true)
            //self.callCheckEmailExistAPI()
            self.callLoginAPI()
        }
    }
    
    @objc func handleTapOutSideTextFieldArea() {
        
        self.txtEmail.resignFirstResponder() // Hide keyboard
        self.viewEmail.layer.borderWidth = 0 // Hide border
        
        self.txtPassword.resignFirstResponder() // Hide keyboard
        self.viewPassword.layer.borderWidth = 0 // Hide border
    }
    
    //    @objc func textFieldEmailDidChange(_ textField: UITextField) {
    //        // Calculate the updated text count
    //        let updatedCount = textField.text?.count ?? 0
    //
    //        // Update your UI based on the updated count here
    //        DispatchQueue.main.async {
    //            // Update your UI elements based on updatedCount
    //            // For example: label.text = "Updated Count: \(updatedCount)"
    //
    //            if updatedCount > 0 {
    //                self.btnMagicLink.backgroundColor = UIColor.appBlue_0066FF()
    //                self.btnMagicLink.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
    //                self.btnMagicLink.isUserInteractionEnabled = true
    //            } else {
    //                self.btnMagicLink.backgroundColor = UIColor.appGray_F2F3F4()
    //                self.btnMagicLink.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
    //                self.btnMagicLink.isUserInteractionEnabled = false
    //            }
    //        }
    //    }
    
    @objc func lblPrivacyPolicyTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
        guard let text = self.lblPrivacyPolicy.text else { return }
        
        let rangePrivacyPolicy = (text as NSString).range(of: "Privacy Policy")
        let rangeTermsOfUse = (text as NSString).range(of: "Terms of Use")
        
        if gestureRecognizer.didTapAttributedTextInLabel(label: self.lblPrivacyPolicy, inRange: rangePrivacyPolicy) {
            print("Privacy Policy tapped")
            let webContentVC = WebContentVC.instantiate(fromAppStoryboard: .Main)
            webContentVC.contentType = .PrivacyPolicy
            // webContentVC.modalPresentationStyle = .fullScreen
            // webContentVC.modalTransitionStyle = .crossDissolve
            // self.present(webContentVC, animated: true, completion: nil)
            navigationController?.pushViewController(webContentVC, animated: true)
            
        } else if gestureRecognizer.didTapAttributedTextInLabel(label: self.lblPrivacyPolicy, inRange: rangeTermsOfUse) {
            print("Terms of Use tapped")
            let webContentVC = WebContentVC.instantiate(fromAppStoryboard: .Main)
            webContentVC.contentType = .Terms
            // webContentVC.modalPresentationStyle = .fullScreen
            // webContentVC.modalTransitionStyle = .crossDissolve
            // self.present(webContentVC, animated: true, completion: nil)
            navigationController?.pushViewController(webContentVC, animated: true)
            
        } else {
            print("Tapped Other Part")
        }
    }
    
    @objc func lblSignUpTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
        guard let text = self.lblSignup.text else { return }
        
        let rangeSignUp = (text as NSString).range(of: "Sign up")
        
        if gestureRecognizer.didTapAttributedTextInLabel(label: self.lblSignup, inRange: rangeSignUp) {
            print("Sign Up tapped")
            // let publicRegisterVC = PublicRegisterVC.instantiate(fromAppStoryboard: .Login)
            // self.navigationController?.pushViewController(publicRegisterVC, animated: true)
            
            self.navigationController?.popViewController(animated: true)
            
        } else {
            print("Tapped Other Part")
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callLoginAPI() {
        
        let url = BaseURL + APIName.kLogin
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kLogin,
                                    APIParamKey.kEmail: self.txtEmail.text ?? "",
                                    APIParamKey.kPassword: self.txtPassword.text ?? "",
                                    APIParamKey.kPushToken: pushNotificationToken,
                                    APIParamKey.kDeviceType: APIFlagValue.kiPhone]
        
        print("pushNotificationToken = \(pushNotificationToken)")
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                
                guard let userDetail = response?.userDetail else { return }
                
                // Set userId in UserDefaults
                UserLocalData.UserID = userDetail.id ?? ""
                UserLocalData.userMode = userDetail.user_mode ?? "0"
                
                if UserLocalData.userMode == "0" || userDetail.subscriptionStatus == "0" { // Load Social Profile
                    
                    // set user mode to 0
                    UserLocalData.userMode = "0"
                    loginUser?.user_mode = "0"
                    
                    self.callGetInfoAPI(needToShowAlertForFailure: true, isFromLoginRegister: true, UserID: UserLocalData.UserID) { isSuccess, response in
                        if isSuccess {
                            self.setNaviationProfileFlow()
                        }
                    }   
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setupPrivacyPolicyAttributes() {
        
        let attributedString = NSMutableAttributedString(string: """
                                                         By continuing you agree with Privacy Policy
                                                         and Terms of Use
                                                         """)
        
        let byContinuingYouAgreeWithRange = (attributedString.string as NSString).range(of: "By continuing you agree with ")
        let byContinuingYouAgreeWithAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appGray_98A2B1(),
            .font: UIFont(name: "RedHatDisplay-Medium", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        ]
        attributedString.addAttributes(byContinuingYouAgreeWithAttributes, range: byContinuingYouAgreeWithRange)
        
        let privacyPolicyRange = (attributedString.string as NSString).range(of: "Privacy Policy")
        let privacyPolicyAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appBlue_0066FF(),
            .font: UIFont(name: "RedHatDisplay-Medium", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
            //.link: "privacy-policy://" // If need to underline then uncomment this line
        ]
        attributedString.addAttributes(privacyPolicyAttributes, range: privacyPolicyRange)
        
        let andRange = (attributedString.string as NSString).range(of: "and ")
        let andAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appGray_98A2B1(),
            .font: UIFont(name: "RedHatDisplay-Medium", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        ]
        attributedString.addAttributes(andAttributes, range: andRange)
        
        let termsOfUseRange = (attributedString.string as NSString).range(of: "Terms of Use")
        let termsOfUseAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appBlue_0066FF(),
            .font: UIFont(name: "RedHatDisplay-Medium", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
            //.link: "terms-of-use://" // If need to underline then uncomment this line
        ]
        attributedString.addAttributes(termsOfUseAttributes, range: termsOfUseRange)
        
        self.lblPrivacyPolicy.attributedText = attributedString
        self.lblPrivacyPolicy.lineBreakMode = .byWordWrapping
        self.lblPrivacyPolicy.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.lblPrivacyPolicyTapped(_:)))
        self.lblPrivacyPolicy.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupSignUpAttributes() {
        
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Sign up")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appBlack_031227(),
            .font: UIFont(name: "RedHatDisplay-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        ]
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: 25))
        
        let signUpRange = (attributedString.string as NSString).range(of: "Sign up")
        let loginAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appBlue_0066FF(),
            .font: UIFont(name: "RedHatDisplay-Medium", size: 14) ?? UIFont.boldSystemFont(ofSize: 14),
            //.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        attributedString.addAttributes(loginAttributes, range: signUpRange)
        
        self.lblSignup.attributedText = attributedString
        self.lblSignup.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.lblSignUpTapped(_:)))
        self.lblSignup.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func hideAllErrorLabels() {
        
        self.lblErrorEmail.isHidden = true
        self.lblErrorPassword.isHidden = true
    }
    
    private func updateLogInButtonState() {
        
        let textFields: [UITextField] = [self.txtEmail, self.txtPassword]
        
        var allFieldsFilled = true
        
        for textField in textFields {
            if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                allFieldsFilled = false
                break
            }
        }
        
        if allFieldsFilled {
            
            self.btnLogIn.backgroundColor = UIColor.appBlue_0066FF()
            self.btnLogIn.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
            self.btnLogIn.isUserInteractionEnabled = true
            
        } else {
            
            self.btnLogIn.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnLogIn.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
            self.btnLogIn.isUserInteractionEnabled = false
        }
    }
    
    
    //@ethan
    private func navigateToReactNativeScreen(userDataDict: [String: Any]) {
        if let navController = self.navigationController {
            let reactNativeVC = ReactNativeViewController()
            reactNativeVC.initialProperties = userDataDict

            // Accessing the bridge from AppDelegate directly
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                reactNativeVC.bridge = appDelegate.bridge
            }

            navController.pushViewController(reactNativeVC, animated: true)
        }
    }
    
    private func setNaviationProfileFlow() {
        
        //To get and update subscription list
        let accountData: [String: Any] = [APIParamKey.kEmail: loginUser?.email ?? "",
                                          APIParamKey.kPassword: self.txtPassword.text ?? "",
                                          APIParamKey.kProfilePic: loginUser?.profile_img ?? "",
                                          APIParamKey.kUserId: UserLocalData.UserID,
                                          APIParamKey.kStatus: APIParamKey.kLogin,
                                          APIParamKey.kName: loginUser?.name ?? ""]
        
        if let oneIndex = arrAccount.lastIndex(where: { oneAccountData in
            return oneAccountData[APIParamKey.kUserId] as? String == UserLocalData.UserID
        }) {
            arrAccount[oneIndex] = accountData
            UserLocalData.arrOfAccountData = arrAccount
        } else {
            arrAccount.append(accountData)
            UserLocalData.arrOfAccountData = arrAccount
        }
        
        self.txtEmail.text = ""
        self.txtPassword.text = ""
        
        // Default ShouldShowTourScreen is false so for the first time it is false once user go through tourPageMasterViewController we'll make it true.
        if UserLocalData.ShouldShowTourScreen == false {
            
            self.hideCustomLoader()
            
            //@ethan
            print("calling userdata event")
            let userDataDict: [String: Any] = ["email": loginUser?.email ?? "", "id": UserLocalData.UserID]
            
            self.navigateToReactNativeScreen(userDataDict: userDataDict)
            
            //let tourPageMasterVC = TourPageMasterViewController.instantiate(fromAppStoryboard: .Tour)
            //self.navigationController?.pushViewController(tourPageMasterVC, animated: true)
            
        } else {
            
            self.hideCustomLoader()
            
            //@ethan
            print("calling userdata event")
            let userDataDict: [String: Any] = ["email": loginUser?.email ?? "", "id": UserLocalData.UserID]
            
            self.navigateToReactNativeScreen(userDataDict: userDataDict)
            
            //@ethan
//            var rootVC: UIViewController
//            let tabbar = MainTabbarController.instantiate(fromAppStoryboard: .Discover)
//            tabbar.selectedIndex = 1 // Select the desired tab index
//            
//            // Set the tab bar controller as the root view controller
//            rootVC = tabbar
//            let navigationController = UINavigationController(rootViewController: rootVC)
//            navigationController.setNavigationBarHidden(true, animated: true)
//            
//            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                if let window = appDelegate.window {
//                    // Now you have access to the window instance.
//                    window.rootViewController = navigationController
//                    window.makeKeyAndVisible()
//                }
//            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - UITextFieldDelegate -
// ----------------------------------------------------------
extension PublicLoginVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtEmail:
                self.viewEmail.layer.borderWidth = 1
                if self.isErrorFoundInEmail {
                    self.viewEmail.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewEmail.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                break
                
            case self.txtPassword:
                self.viewPassword.layer.borderWidth = 1
                self.viewPassword.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                break
                
            default:
                break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtEmail:
                self.viewEmail.layer.borderWidth = 0
                break
                
            case self.txtPassword:
                self.viewPassword.layer.borderWidth = 0
                break
                
            default:
                break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
                
            case self.txtEmail:
                self.txtPassword.becomeFirstResponder()
                break
                
            case self.txtPassword:
                self.txtPassword.resignFirstResponder()
                
            default:
                break
        }
        return true
    }
}
