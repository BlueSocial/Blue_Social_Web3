//
//  EmailOTPVerificationVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import Toast_Swift

class EmailOTPVerificationVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var btnBack              : UIButton!
    @IBOutlet weak var otpView              : VPMOTPView!
    @IBOutlet weak var lblErrorOTP          : UILabel!
    @IBOutlet weak var btnVerifyOTP         : CustomButton!
    @IBOutlet weak var lblTitle             : UILabel!
    @IBOutlet weak var lblEnterOTPTitle     : UILabel!
    @IBOutlet weak var lblEmail             : UILabel!
    
    @IBOutlet weak var imgViewCone          : UIImageView! // Public
    @IBOutlet weak var imgViewRock          : UIImageView! // Public
    @IBOutlet weak var imgViewSphere        : UIImageView! // Student
    @IBOutlet weak var imgViewTorus         : UIImageView! // Student
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var isErrorFoundInOTP: Bool = false
    typealias OTPVerificationCompletion = (_ isOTPVerified: Bool) -> Void
    private var otpVerificationStatusCompletion: OTPVerificationCompletion?
    internal var isStudent: Bool = false // For decide navigate to StudentLoginVC || PublicLoginVC
    internal var isForgetPassword: Bool = false // For decide navigate to ChangePasswordVC || send callBack to Register Screen
    fileprivate var userVerificationID: String?
    internal var emailForOTP: String = ""
    internal var otp: String = ""
    private var hasEnteredAllOtp = false
    private var enteredOTP: String = ""
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupOTPView()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------
extension EmailOTPVerificationVC  {
    
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
        if self.otpVerificationStatusCompletion != nil {
            self.otpVerificationStatusCompletion!(false)
        }
    }
    
    @IBAction func onBtnVerifyOTP(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.isForgetPassword {
            
            self.callVerifyOTPEmailAPI()
            
        } else { // Student || callSendOtpEmailAPI from ChangeEmailVC
            
            if self.otp == self.enteredOTP {
                
                self.navigationController?.popViewController(animated: true)
                if self.otpVerificationStatusCompletion != nil {
                    self.otpVerificationStatusCompletion!(true)
                }
                
            } else {
                
                self.isErrorFoundInOTP = true
                self.lblErrorOTP.isHidden = false
                self.lblErrorOTP.text = "OTP does not match please try again!"
                
                if self.otpVerificationStatusCompletion != nil {
                    self.otpVerificationStatusCompletion!(false)
                }
            }
        }
    }
    
    @objc func handleTapOutSideTextFieldArea() {
        
        self.otpView.endEditing(true)
    }
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension EmailOTPVerificationVC {
    
    private func callVerifyOTPEmailAPI() {
        
        let url = BaseURL + APIName.kVerifyOtpEmail
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kVerifyOtp,
                                    APIParamKey.kEmail: self.emailForOTP,
                                    APIParamKey.kOTP: self.enteredOTP]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
            } else {
                
                self.isErrorFoundInOTP = true
                self.lblErrorOTP.isHidden = false
                self.lblErrorOTP.text = msg
                
                if self.otpVerificationStatusCompletion != nil {
                    self.otpVerificationStatusCompletion!(false)
                }
            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - Function -
// ----------------------------------------------------------
extension EmailOTPVerificationVC {
    
    private func setupUI() {
        
        if self.isStudent == true {
            
            self.imgViewCone.isHidden = true
            self.imgViewRock.isHidden = true
            self.imgViewSphere.isHidden = false
            self.imgViewTorus.isHidden = false
            
        } else {
            
            self.imgViewCone.isHidden = false
            self.imgViewRock.isHidden = false
            self.imgViewSphere.isHidden = true
            self.imgViewTorus.isHidden = true
        }
        
        self.lblEmail.text = self.emailForOTP
        self.lblErrorOTP.isHidden = true
        
        self.btnVerifyOTP.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnVerifyOTP.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
        self.btnVerifyOTP.isUserInteractionEnabled = false
        
        // Add tap gesture recognizer to dismiss keyboard and hide border
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOutSideTextFieldArea))
        view.addGestureRecognizer(self.tapGestureRecognizer)
    }
    
    private func updateSubmitButtonState() {
        
        if self.hasEnteredAllOtp {
            
            self.btnVerifyOTP.backgroundColor = UIColor.appBlue_0066FF()
            self.btnVerifyOTP.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
            self.btnVerifyOTP.isUserInteractionEnabled = true
            
        } else {
            
            self.btnVerifyOTP.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnVerifyOTP.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
            self.btnVerifyOTP.isUserInteractionEnabled = false
        }
    }
    
    internal func otpVerificationStatusCallBack(completion: @escaping (_ isOTPVerified: Bool) -> ()) {
        self.otpVerificationStatusCompletion = completion
    }
    
    private func setupOTPView() {
        
        self.otpView.delegate                           = self
        self.otpView.otpFieldSize                       = 42 // (UIScreen.main.bounds.width - 48 - 85) / 6
        self.otpView.otpFieldsCount                     = 4
        self.otpView.otpFieldDefaultBorderColor         = UIColor.init(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)
        self.otpView.otpFieldEnteredBorderColor         = UIColor.init(red: 0, green: 130.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        self.otpView.otpFieldBorderWidth                = 1
        self.otpView.otpFieldDisplayType                = .square
        self.otpView.otpFieldTextColor                  = UIColor.appBlack_000000()
        self.otpView.cursorColor                        = UIColor.appBlack_000000()
        self.otpView.otpFieldDefaultBackgroundColor     = UIColor.init(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
        self.otpView.shouldAllowIntermediateEditing     = true
        self.otpView.layoutIfNeeded()
        
        // Create the UI
        self.otpView.initializeUI()
    }
}

// ----------------------------------------------------------
//                       MARK: - VPMOTPViewDelegate -
// ----------------------------------------------------------
extension EmailOTPVerificationVC: VPMOTPViewDelegate {
    
    func enteredOTP(otpString: String) {
        
        self.enteredOTP = otpString
        print("enteredOTP = \(otpString)")
        
        if self.enteredOTP == "" || self.enteredOTP.count < 4 {
            self.showAlertWithOKButton(message: kPlease_enter_OTP)
            return
        }
    }
    
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        self.hasEnteredAllOtp = hasEntered
        
        self.updateSubmitButtonState()
        
        return hasEntered
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
}
