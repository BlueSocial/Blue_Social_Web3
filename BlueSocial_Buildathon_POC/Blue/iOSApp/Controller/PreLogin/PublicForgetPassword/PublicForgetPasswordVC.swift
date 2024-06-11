//
//  PublicForgetPasswordVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class PublicForgetPasswordVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblErrorEmail: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var viewEmail: CustomView!
    
    @IBOutlet weak var btnSendCode: CustomButton!
    @IBOutlet weak var btnCreateAnAccount: CustomButton!
    
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
        
        self.lblErrorEmail.isHidden = true
        
        self.btnSendCode.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnSendCode.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
        self.btnSendCode.isUserInteractionEnabled = false
        
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
        
        self.updateSendCodeButtonState()
    }
    
    @IBAction func onBtnSendCode(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if !self.txtEmail.text!.isValidEmail() {
            self.lblErrorEmail.isHidden = false
            self.lblErrorEmail.text = "Invalid email"
            self.viewEmail.BordeHeight = 1
            self.viewEmail.BordeColor = UIColor.appRed_E13C3C()
            self.isErrorFoundInEmail = true
            
        } else if let email = self.txtEmail.text, email.hasSuffix(".edu") {
            self.lblErrorEmail.isHidden = false
            self.lblErrorEmail.text = "Please select a student network to get OTP on this email"
            self.viewEmail.BordeHeight = 1
            self.viewEmail.BordeColor = UIColor.appRed_E13C3C()
            self.isErrorFoundInEmail = true
            
        } else {
            self.view.endEditing(true)
            self.callCheckEmailExistAPI()
        }
    }
    
    @IBAction func onBtnCreateAnAccount(_ sender: UIButton) {
        
        //        let vc = PublicRegisterVC.instantiate(fromAppStoryboard: .Login)
        //        self.navigationController?.pushViewController(vc, animated: true)
        
        if let navigationController = self.navigationController {
            
            // Check if PublicRegisterVC is in the navigation stack
            if navigationController.viewControllers.contains(where: { $0 is PublicRegisterVC }) {
                // Pop to PublicRegisterVC
                for viewController in navigationController.viewControllers {
                    if viewController is PublicRegisterVC {
                        navigationController.popToViewController(viewController, animated: true)
                        break
                    }
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func handleTapOutSideTextFieldArea() {
        self.txtEmail.resignFirstResponder() // Hide keyboard
        self.viewEmail.layer.borderWidth = 0 // Hide border
    }
    
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
                        self.callSendOtpEmailAPI()
                        
                    } else {
                        self.lblErrorEmail.isHidden = false
                        self.lblErrorEmail.text = "Sorry, we couldn't find an account associated with this email address"
                        self.viewEmail.BordeHeight = 1
                        self.viewEmail.BordeColor = UIColor.appRed_E13C3C()
                        self.isErrorFoundInEmail = true
                    }
                    
                } else {
                    
                    self.lblErrorEmail.isHidden = false
                    self.lblErrorEmail.text = "Sorry, we couldn't find an account associated with this email address"
                    self.viewEmail.BordeHeight = 1
                    self.viewEmail.BordeColor = UIColor.appRed_E13C3C()
                    self.isErrorFoundInEmail = true
                }
                
            } else {
                
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callSendOtpEmailAPI() {
        
        let url = BaseURL + APIName.kSendOtpEmail
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kSentOtp,
                                    APIParamKey.kEmail: self.txtEmail.text!.trime()]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param)  { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                let emailOTPVerificationVC = EmailOTPVerificationVC.instantiate(fromAppStoryboard: .Login)
                emailOTPVerificationVC.isStudent = false
                emailOTPVerificationVC.isForgetPassword = true
                emailOTPVerificationVC.emailForOTP = self.txtEmail.text!.trime()
                self.navigationController?.pushViewController(emailOTPVerificationVC, animated: true)
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func updateSendCodeButtonState() {
        
        let textFields: [UITextField] = [self.txtEmail]
        
        var allFieldsFilled = true
        
        for textField in textFields {
            if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                allFieldsFilled = false
                break
            }
        }
        
        if allFieldsFilled {
            
            self.btnSendCode.backgroundColor = UIColor.appBlue_0066FF()
            self.btnSendCode.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
            self.btnSendCode.isUserInteractionEnabled = true
            
        } else {
            
            self.btnSendCode.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnSendCode.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
            self.btnSendCode.isUserInteractionEnabled = false
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - UITextFieldDelegate -
// ----------------------------------------------------------
extension PublicForgetPasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
                
            case self.txtEmail:
                self.txtEmail.resignFirstResponder()
                break
                
            default:
                break
        }
        return true
    }
    
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
                
            default:
                break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtEmail:
                self.viewEmail.layer.borderWidth = 0
                break
                
            default:
                break
        }
    }
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        
    //        //let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
    //        //let updatedStringCount = (textField.text ?? "").count + string.count - range.length
    //        
    //        // Calculate the new length of the text if the replacement string is applied
    //        let currentText = textField.text ?? ""
    //        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
    //        
    //        switch textField {
    //                
    //            case self.txtEmail:
    //                // Check if the replacement string contains any emojis
    //                if string.containsEmoji {
    //                    return false // Prevent emojis from being entered
    //                }
    //                
    //                return true
    //                
    //            default:
    //                break
    //        }
    //        
    //        return true
    //    }
}
