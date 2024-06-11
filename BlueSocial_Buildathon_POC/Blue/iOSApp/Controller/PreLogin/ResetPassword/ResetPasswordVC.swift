//
//  ResetPasswordVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class ResetPasswordVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var txtNewPassWord       : UITextField!
    @IBOutlet weak var txtRetypePassWord    : UITextField!
    @IBOutlet weak var btnSignuUp           : CustomButton!
    @IBOutlet weak var lblDontAccount       : UILabel!
    @IBOutlet weak var btnSubmit            : CustomButton!
    @IBOutlet weak var btnBackToLogin       : UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var emailForOtp = ""
    var otp         = ""
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnSignuUp.isHorizontal = true
        self.btnSignuUp.firstGradientColor = AppTheme.RightBlue
        self.btnSignuUp.secondGradientColor = AppTheme.LeftBlue
        
        self.btnSubmit.isHorizontal = true
        self.btnSubmit.firstGradientColor = AppTheme.RightBlue
        self.btnSubmit.secondGradientColor = AppTheme.LeftBlue
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------
extension ResetPasswordVC {
    
    @IBAction func btnSubmit_Click(_ sender: UIButton) {
        
        if self.txtNewPassWord.text!.trime().count < 1 {
            self.showAlertWithOKButton(message: kPlease_enter_new_password)
            
        } else if self.txtRetypePassWord.text!.trime().count < 1 {
            self.showAlertWithOKButton(message: kPlease_enter_Retype_Password)
            
        } else if self.txtNewPassWord.text!.trime() != txtRetypePassWord.text!.trime() {
            self.showAlertWithOKButton(message: kPasswords_on_both_fields)
            
        } else {
            self.view.endEditing(true)
            self.callResetPasswordAPI()
        }
    }
    
    @IBAction func btnSignup_Click(_ sender: UIButton) {
        
    }
    
    @IBAction func btnBackToLoginClick(_ sender: UIButton) {
        
        self.gotoLoginScreen()
    }
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension ResetPasswordVC {
    
    private func callResetPasswordAPI() {
        
        let url = BaseURL + APIName.kResetPassword
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kResetPassword,
                                    APIParamKey.kEmail: emailForOtp,
                                    APIParamKey.kPassword: txtNewPassWord.text!.trime(),
                                    APIParamKey.kRPassword: txtRetypePassWord.text!.trime(),
                                    APIParamKey.kOTP: self.otp]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                self.gotoLoginScreen()
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - UITextFieldDelegate -
// ----------------------------------------------------------
extension ResetPasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtNewPassWord {
            self.txtRetypePassWord.becomeFirstResponder()
            
        } else {
            self.view.endEditing(true)
        }
        return true
    }
}

// ----------------------------------------------------------
//                       MARK: - Function -
// ----------------------------------------------------------
extension ResetPasswordVC {
    
    private func gotoLoginScreen() {
        
        //        for controller in navigationController!.viewControllers {
        //            
        //            if controller.isKind(of: LoginVC.self) {
        //                navigationController?.popToViewController(controller, animated: true)
        //            }
        //        }
    }
}
