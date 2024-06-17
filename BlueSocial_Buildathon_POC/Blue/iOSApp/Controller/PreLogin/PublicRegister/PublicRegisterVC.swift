//
//  PublicRegisterVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import SKCountryPicker
import MobileCoreServices
import FirebaseAuth

class PublicRegisterVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblErrorFirstName: UILabel!
    @IBOutlet weak var lblErrorLastName: UILabel!
    @IBOutlet weak var lblErrorEmail: UILabel!
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    @IBOutlet weak var lblErrorPassword: UILabel!
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtPassword: NoCopyPasteTextField!
    
    @IBOutlet weak var viewFirstName: CustomView!
    @IBOutlet weak var viewLastName: CustomView!
    @IBOutlet weak var viewEmail: CustomView!
    @IBOutlet weak var viewPhoneNumber: CustomView!
    @IBOutlet weak var viewPassword: CustomView!
    @IBOutlet weak var btnEyeOPenClose: UIButton!
    
    @IBOutlet weak var viewCountryFlag_Code: UIView!
    @IBOutlet weak var imgCountryFlag: UIImageView!
    @IBOutlet weak var lblCountryCode: UILabel!
    
    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var btnRegister: UIButton! // btnCreateWallet
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private var isErrorFoundInFirstName: Bool = false
    private var isErrorFoundInLastName: Bool = false
    private var isErrorFoundInEmail: Bool = false
    private var issErrorFoundInPhoneNum: Bool = false
    private var isErrorFoundInPassword: Bool = false
    
    private var isAuth = "0"
    private var otp = ""
    
    private var phoneCountryNameCode = "us"
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideAllErrorLabels()
        self.setupUIForBtnRegister()
        self.setupPrivacyPolicyAttributes()
        // self.setupLoginAttributes()
        
        self.txtPassword.isSecureTextEntry = true
        self.btnEyeOPenClose.setImage(UIImage(named: "ic_eye_close"), for: .normal)
        
        // Add tap gesture recognizer to dismiss keyboard and hide border
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOutSideTextFieldArea))
        view.addGestureRecognizer(self.tapGestureRecognizer)
        
        self.txtFirstName.keyboardType = .alphabet
        self.txtLastName.keyboardType = .alphabet
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
    
    @IBAction func onBtnLogin(_ sender: UIButton) {
        
        let publicLoginVC = PublicLoginVC.instantiate(fromAppStoryboard: .Login)
        self.navigationController?.pushViewController(publicLoginVC, animated: true)
    }
    
    @IBAction func textFieldEditingChanged(_ senders: [UITextField]) {
        self.updateRegisterButtonState()
    }
    
    @IBAction func textFieldPhonNumberEditingChanged(_ sender: UITextField) {
        
        if self.txtPhoneNumber.text?.count ?? 0 < 7 {
            self.lblErrorPhoneNumber.isHidden = false
            self.viewPhoneNumber.BordeHeight = 1
            self.viewPhoneNumber.BordeColor = UIColor.appRed_E13C3C()
        } else {
            self.lblErrorPhoneNumber.isHidden = true
            self.viewPhoneNumber.BordeHeight = 1
            self.viewPhoneNumber.BordeColor = UIColor.appGray_F2F3F4()
        }
    }
    
    @IBAction func textFieldPasswordEditingChanged(_ senders: UITextField) {
        
        if let error = self.checkPasswordValidity(password: senders.text ?? "") {
            self.lblErrorPassword.isHidden = false
            self.lblErrorPassword.text = error
            self.viewPassword.BordeHeight = 1
            self.viewPassword.BordeColor = UIColor.appRed_E13C3C()
            self.isErrorFoundInPassword = true
        } else {
            self.lblErrorPassword.isHidden = true
            self.viewPassword.BordeHeight = 1
            self.viewPassword.BordeColor = UIColor.appBlue_0066FF()
            self.isErrorFoundInPassword = false
        }
        
        self.updateRegisterButtonState()
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
    
    @IBAction func onBtnCountryCode(_ sender: UIButton) {
        
        let _ = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            guard let self = self else { return }
            
            self.imgCountryFlag.image = country.flag
            self.lblCountryCode.text = country.dialingCode
            self.phoneCountryNameCode = country.countryCode.lowercased()
        }
    }
    
    // Now btnRegister referred as btnCreateWallet
    @IBAction func onBtnRegister(_ sender: UIButton) {
        print("Button Create Wallet Tapped")
        
        // FirstName & LastName min 2 max 20 char
        // Invalid email
        // Please select a student network to register with this email if isValidEmail + .edu i.e. email@stanford.edu
        
        if self.txtFirstName.text?.trime().count ?? 0 < 2 {
            self.lblErrorFirstName.isHidden = false
            self.lblErrorFirstName.text = alertFirstNameShouldContainMinTwoChar
            self.viewFirstName.BordeHeight = 1
            self.viewFirstName.BordeColor = UIColor.appRed_E13C3C()
            self.isErrorFoundInFirstName = true
            
        } else if self.txtLastName.text?.trime().count ?? 0 < 2 {
            self.lblErrorLastName.isHidden = false
            self.lblErrorLastName.text = alertLastNameShouldContainMinTwoChar
            self.viewLastName.BordeHeight = 1
            self.viewLastName.BordeColor = UIColor.appRed_E13C3C()
            self.isErrorFoundInLastName = true
            
        } else if !self.txtEmail.text!.isValidEmail() {
            self.lblErrorEmail.isHidden = false
            self.lblErrorEmail.text = alertInvalidEmail
            self.viewEmail.BordeHeight = 1
            self.viewEmail.BordeColor = UIColor.appRed_E13C3C()
            self.isErrorFoundInEmail = true
            
        } else if self.txtPhoneNumber.text!.count < 7 {
            self.lblErrorPhoneNumber.isHidden = false
            self.lblErrorEmail.text = alertInvalidPhoneNumber
            self.viewPhoneNumber.BordeHeight = 1
            self.viewPhoneNumber.BordeColor = UIColor.appRed_E13C3C()
            self.issErrorFoundInPhoneNum = true
            
        } else {
            self.view.endEditing(true)
            self.callCheckEmailExistAPI()
        }
    }
    
    @objc func handleTapOutSideTextFieldArea() {
        
        self.txtFirstName.resignFirstResponder() // Hide keyboard
        self.viewFirstName.layer.borderWidth = 0 // Hide border
        
        self.txtLastName.resignFirstResponder() // Hide keyboard
        self.viewLastName.layer.borderWidth = 0 // Hide border
        
        self.txtEmail.resignFirstResponder() // Hide keyboard
        self.viewEmail.layer.borderWidth = 0 // Hide border
        
        self.txtPhoneNumber.resignFirstResponder() // Hide keyboard
        self.viewPhoneNumber.layer.borderWidth = 0 // Hide border
        
        self.txtPassword.resignFirstResponder() // Hide keyboard
        self.viewPassword.layer.borderWidth = 0 // Hide border
    }
    
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
    
    //    @objc func lblLoginTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    //
    //        guard let text = self.lblLogin.text else { return }
    //
    //        let rangeLogin = (text as NSString).range(of: "Log in")
    //
    //        if gestureRecognizer.didTapAttributedTextInLabel(label: self.lblLogin, inRange: rangeLogin) {
    //            print("Log in tapped")
    //
    //            if let navigationController = self.navigationController {
    //                // Check if PublicLoginVC is in the navigation stack
    //                if navigationController.viewControllers.contains(where: { $0 is PublicLoginVC }) {
    //                    // Pop to PublicLoginVC
    //                    for viewController in navigationController.viewControllers {
    //                        if viewController is PublicLoginVC {
    //                            navigationController.popToViewController(viewController, animated: true)
    //                            break
    //                        }
    //                    }
    //                } else {
    //                    // Push LoginVC onto the stack
    //                    let publicLoginVC = PublicLoginVC() // Create an instance of your LoginVC
    //                    navigationController.pushViewController(publicLoginVC, animated: true)
    //                }
    //            }
    //
    //        } else {
    //            print("Tapped Other Part")
    //        }
    //    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callCheckEmailExistAPI() {
        
        let url = BaseURL + APIName.kGetEmailCheck
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kEmailCheck,
                                    APIParamKey.kEmail: self.txtEmail.text!.trime()]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            self.hideCustomLoader()
            
            if isSucess {
                
                if response?.data != nil {
                    
                    if response?.status == "Error" && msg == "Email already Registered" {
                        
                        self.lblErrorEmail.isHidden = false
                        self.lblErrorEmail.text = ALERT_EmailAlreadyRegistered
                        self.viewEmail.BordeHeight = 1
                        self.viewEmail.BordeColor = UIColor.appRed_E13C3C()
                        self.isErrorFoundInEmail = true
                        
                    } else if response?.status == "Success" && msg == "" {
                        
                        // Here can implement react code which gives us Wallet Address
                        self.navigateToPhoneOTPVerificationVC()
                    }
                }
                
            } else {
                
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callRegisterAPI() {
        
        let url = BaseURL + APIName.kRegister
        let user_referral_code = UserLocalData.referalCode
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kSignup,
                                    APIParamKey.kName: "\(self.txtFirstName.text?.trime() ?? "") \(self.txtLastName.text?.trime() ?? "")",
                                    APIParamKey.kFirstName: self.txtFirstName.text?.trime() ?? "",
                                    APIParamKey.kLastName: self.txtLastName.text?.trime() ?? "",
                                    APIParamKey.kEmail: self.txtEmail.text?.trime() ?? "",
                                    APIParamKey.kPassword: self.txtPassword.text?.trime() ?? "",
                                    APIParamKey.kMobile: "\(self.phoneCountryNameCode)_\(self.lblCountryCode.text ?? "")_\(self.txtPhoneNumber.text?.trime() ?? "")",
                                    APIParamKey.kPushToken: pushNotificationToken,
                                    APIParamKey.kDeviceType: APIFlagValue.kiPhone,
                                    APIParamKey.kIsAuth: self.isAuth, // isEmailOTPVerified
                                    APIParamKey.kProfessionType: "1", // Public: "1", Student: "2"
                                    APIParamKey.kUser_referral_code: user_referral_code]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            
            if isSucess {
                
                let data = (response?.register)
                
                if let userdata = UserDetail(JSON: (data?.toJSON())!) {
                    
                    UserLocalData.UserID = userdata.id ?? ""
                    
                    var registerUser = UserDetail()
                    registerUser.subscriptionStatus = "1"
                    registerUser.firstname = userdata.firstname?.trime() ?? ""
                    registerUser.lastname  = userdata.lastname?.trime() ?? ""
                    registerUser.mobile    = userdata.mobile ?? ""
                    registerUser.password  = userdata.password ?? ""
                    registerUser.email     = userdata.email?.trime() ?? ""
                    registerUser.is_auth   = userdata.is_auth ?? ""
                    registerUser.name      = userdata.name ?? ""
                    registerUser.id        = userdata.id ?? ""
                    loginUser              = registerUser
                    
                    if arrAccount.count <= 4 {
                        
                        let accountdata: [String: Any] = [APIParamKey.kEmail: userdata.email?.trime() ?? "",
                                                          APIParamKey.kPassword: userdata.password?.trime() ?? "",
                                                          APIParamKey.kProfilePic: userdata.profile_img ?? "",
                                                          APIParamKey.kUserId: UserLocalData.UserID,
                                                          APIParamKey.kStatus: APIParamKey.kLogin,
                                                          APIParamKey.kName: userdata.name ?? ""]
                        
                        arrAccount.append(accountdata)
                        
                        UserLocalData.arrOfAccountData = arrAccount
                    }
                    
                    self.hideCustomLoader()
                    
                    let tourPageMasterVC = TourPageMasterViewController.instantiate(fromAppStoryboard: .Tour)
                    tourPageMasterVC.isFromRegister = true
                    self.navigationController?.pushViewController(tourPageMasterVC, animated: true)
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callUpdateWalletAddressAPI() {
        
        let url = BaseURL + APIName.kUpdateWalletAddress
        
        let param: [String: Any] = [APIParamKey.kUser_Id: UserLocalData.UserID,
                                    APIParamKey.kWalletAddress: ""]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            self.hideCustomLoader()
            
            if isSucess {
                
                
                
            } else {
                
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setupUIForBtnRegister() {
        
        self.btnRegister.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnRegister.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
        self.btnRegister.isUserInteractionEnabled = false
    }
    
    private func updateRegisterButtonState() {
        
        let textFields: [UITextField] = [self.txtFirstName, self.txtLastName, self.txtEmail, self.txtPhoneNumber, self.txtPassword,]
        
        var allFieldsFilled = true
        
        for textField in textFields {
            if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                allFieldsFilled = false
                break
            }
        }
        
        if allFieldsFilled && self.lblErrorPassword.isHidden == true && self.txtPhoneNumber.text?.count ?? 0 > 6 {
            
            self.btnRegister.backgroundColor = UIColor.appBlue_0066FF()
            self.btnRegister.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
            self.btnRegister.isUserInteractionEnabled = true
            
//            if let image = UIImage(systemName: "ic_create_wallet") {
//                self.btnRegister.setImage(image, for: .normal)
//            }
            
        } else {
            
            self.btnRegister.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnRegister.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
            self.btnRegister.isUserInteractionEnabled = false
            
//            if let image = UIImage(systemName: "ic_create_wallet") {
//                self.btnRegister.setImage(image, for: .normal)
//            }
        }
    }
    
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
    
    //    private func setupLoginAttributes() {
    //
    //        let attributedString = NSMutableAttributedString(string: "Already have an account? Log in")
    //        let attributes: [NSAttributedString.Key: Any] = [
    //            .foregroundColor: UIColor.appBlack_031227(),
    //            .font: UIFont(name: "RedHatDisplay-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
    //        ]
    //        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: 25))
    //
    //        let loginRange = (attributedString.string as NSString).range(of: "Log in")
    //        let loginAttributes: [NSAttributedString.Key: Any] = [
    //            .foregroundColor: UIColor.appBlue_0066FF(),
    //            .font: UIFont(name: "RedHatDisplay-Medium", size: 14) ?? UIFont.boldSystemFont(ofSize: 14),
    //            //.underlineStyle: NSUnderlineStyle.single.rawValue
    //        ]
    //        attributedString.addAttributes(loginAttributes, range: loginRange)
    //
    //        self.lblLogin.attributedText = attributedString
    //        self.lblLogin.isUserInteractionEnabled = true
    //
    //        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.lblLoginTapped(_:)))
    //        self.lblLogin.addGestureRecognizer(tapGestureRecognizer)
    //    }
    
    private func hideAllErrorLabels() {
        
        self.lblErrorFirstName.isHidden = true
        self.lblErrorLastName.isHidden = true
        self.lblErrorEmail.isHidden = true
        self.lblErrorPhoneNumber.isHidden = true
        self.lblErrorPassword.isHidden = true
    }
    
    private func navigateToPhoneOTPVerificationVC() {
        
        let phoneOTPVerificationVC = PhoneOTPVerificationVC.instantiate(fromAppStoryboard: .Login)
        phoneOTPVerificationVC.mobileNo = "(\(self.lblCountryCode.text ?? "")) \(self.txtPhoneNumber.text ?? "")"
        
        phoneOTPVerificationVC.otpVerificationStatusCallBack { isOTPVerified in
            
            if isOTPVerified {
                
                self.callRegisterAPI()
            }
        }
        
        self.navigationController?.pushViewController(phoneOTPVerificationVC, animated: true)
    }
}

// ----------------------------------------------------------
//                       MARK: - UITextFieldDelegate -
// ----------------------------------------------------------
extension PublicRegisterVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Calculate the new length of the text if the replacement string is applied
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
                
            case self.txtFirstName, self.txtLastName:
                
                // Allow only letters in the text field
                let allowedCharacters = CharacterSet.letters
                let characterSet = CharacterSet(charactersIn: string)
                
                if !allowedCharacters.isSuperset(of: characterSet) {
                    return false
                }
                
                return newText.count <= 20 // Allow only if the new length is 20 or less
                
            case self.txtEmail:
                break
                
            default:
                break
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtFirstName:
                self.viewFirstName.layer.borderWidth = 1
                if self.isErrorFoundInFirstName {
                    self.viewFirstName.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewFirstName.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                break
                
            case self.txtLastName:
                self.viewLastName.layer.borderWidth = 1
                if self.isErrorFoundInLastName {
                    self.viewLastName.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewLastName.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                break
                
            case self.txtEmail:
                self.viewEmail.layer.borderWidth = 1
                if self.isErrorFoundInEmail {
                    self.viewEmail.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewEmail.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                break
                
            case self.txtPhoneNumber:
                self.viewPhoneNumber.layer.borderWidth = 1
                if self.issErrorFoundInPhoneNum {
                    self.viewPhoneNumber.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewPhoneNumber.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                break
                
            case self.txtPassword:
                self.viewPassword.layer.borderWidth = 1
                if self.isErrorFoundInPassword {
                    self.viewPassword.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewPassword.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                break
                
            default:
                break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
                
            case self.txtFirstName:
                self.txtLastName.becomeFirstResponder()
                break
                
            case self.txtLastName:
                self.txtEmail.becomeFirstResponder()
                break
                
            case self.txtEmail:
                self.txtPhoneNumber.becomeFirstResponder()
                break
                
            case self.txtPhoneNumber:
                self.txtPassword.becomeFirstResponder()
                break
                
            case self.txtPassword:
                self.txtPassword.resignFirstResponder()
                break
                
            default:
                break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtFirstName:
                self.viewFirstName.layer.borderWidth = 0
                break
                
            case self.txtLastName:
                self.viewLastName.layer.borderWidth = 0
                break
                
            case self.txtEmail:
                self.viewEmail.layer.borderWidth = 0
                break
                
            case self.txtPhoneNumber:
                self.viewPhoneNumber.layer.borderWidth = 0
                break
                
            case self.txtPassword:
                self.viewPassword.layer.borderWidth = 0
                break
                
            default:
                break
        }
    }
}
