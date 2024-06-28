//
//  PhoneOTPVerificationVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import FirebaseAuth
import Toast_Swift

class PhoneOTPVerificationVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var btnBack              : UIButton!
    @IBOutlet weak var otpView              : VPMOTPView!
    @IBOutlet weak var lblErrorOTP          : UILabel!    
    @IBOutlet weak var btnVerifyOTP         : CustomButton!
    @IBOutlet weak var btnResendCode        : UIButton!
    @IBOutlet weak var lblCodeExpireCounter : UILabel!
    @IBOutlet weak var lblTitle             : UILabel!
    @IBOutlet weak var lblMobileNumber      : UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var isErrorFoundInOTP: Bool = false
    fileprivate var timer = Timer()
    fileprivate var count = 60
    typealias OTPVerificationCompletion = (_ isOTPVerified: Bool) -> Void
    private var otpVerificationStatusCompletion: OTPVerificationCompletion?
    var mobileNo = ""
    fileprivate var userVerificationID: String?
    private var hasEnteredAllOtp = false
    private var enteredOTP: String = ""
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblMobileNumber.setUpAttributedWithDifferentColorAndFont(text: "Enter the code sent to ", textUnit: self.mobileNo, textcolor: UIColor.appGray_98A2B1(), textUnitColor: UIColor.appBlack_000000(), textFont: UIFont(name: "RedHatDisplay-Medium", size: 14) ?? UIFont.boldSystemFont(ofSize: 14), textUnitFont: UIFont(name: "RedHatDisplay-Medium", size: 14) ?? UIFont.boldSystemFont(ofSize: 14))
        
        self.setupOTPView()
        
        self.lblCodeExpireCounter.isHidden = true
        
        self.lblErrorOTP.isHidden = true
        
        self.btnVerifyOTP.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnVerifyOTP.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
        self.btnVerifyOTP.isUserInteractionEnabled = false
        
        // Add tap gesture recognizer to dismiss keyboard and hide border
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOutSideTextFieldArea))
        view.addGestureRecognizer(self.tapGestureRecognizer)
        
        self.sendMobileOTP()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------


extension PhoneOTPVerificationVC {
    
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
        if self.otpVerificationStatusCompletion != nil {
            self.otpVerificationStatusCompletion!(false)
        }
    }
    
    @IBAction func onBtnResendClick(_ sender: UIButton) {
        
        self.sendMobileOTP()
    }
    
    @IBAction func onBtnVerifyOTP(_ sender: UIButton) {
        self.view.endEditing(true)
        
        self.validateOTPWithFirebase()
    }
    
    @objc func handleTapOutSideTextFieldArea() {
        
        self.otpView.endEditing(true)
    }
    
    @objc func startTimer() {
        
        if self.count >= 0 {
            
            self.lblCodeExpireCounter.threePartWithDifferentColorAndFont(
                partOneString: "Code expires in ",
                partOneFont: UIFont(name: "RedHatDisplay-SemiBold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14),
                partOneColor: UIColor.appGray_98A2B1(),
                
                partTwoString: "\(self.count)",
                partTwoFont: UIFont(name: "RedHatDisplay-SemiBold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14),
                partTwoColor: UIColor.appBlue_0066FF(),
                
                partThreeString: " seconds",
                partThreeFont: UIFont(name: "RedHatDisplay-SemiBold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14),
                partThreeColor: UIColor.appGray_98A2B1())
            
            self.count -= 1
            
        } else {
            self.stopTimer()
        }
    }
    
    fileprivate func stopTimer() {
        
        self.timer.invalidate()
        self.count = 60
        self.lblCodeExpireCounter.isHidden = true
        self.btnResendCode.isHidden = false
    }
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension PhoneOTPVerificationVC {
    
    private func navigateToReactNativeScreen() { //@ethan
        if let navController = self.navigationController {
            let reactNativeVC = ReactNativeViewController()
            navController.pushViewController(reactNativeVC, animated: true)
        }
    }
    
    fileprivate func sendMobileOTP() {
        
        let phoneNumber = self.mobileNo
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            
            if let err = error {
                print(err.localizedDescription)
                self.stopTimer()
                self.btnResendCode.isHidden = true
                
                self.showAlertWithOKButton(message: "Please add a phone number that is verifiable.", title: "Phone number is Invalid", {
                    self.navigationController?.popViewController(animated: true)
                })
                
            } else {
                
                self.userVerificationID = verificationID
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.view.makeToast("OTP send to your mobile number: \(self.mobileNo)")
                }
                
                self.count = 60
                self.btnResendCode.isHidden = true
                self.lblCodeExpireCounter.isHidden = false
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    func validateOTPWithFirebase() {
        
        if self.userVerificationID != nil {
            
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: self.userVerificationID!,
                verificationCode: self.enteredOTP)
            
            self.showCustomLoader()
            Auth.auth().signIn(with: credential) { (user, error) in
                self.hideCustomLoader()
                
                if error != nil {
                    self.showAlertWithOKButton(message: ALERT_Invalid_OTP)
                    
                } else {
                    self.stopTimer()
                    self.lblCodeExpireCounter.isHidden = true
                    self.btnResendCode.isHidden = true
                    
                    // Call the completion handler if available
                    if let completion = self.otpVerificationStatusCompletion {
                        completion(true)
                    }
                    
                    // Transition to React Native screen @ethan
                    //self.navigateToReactNativeScreen()
                }
            }
            
        } else {
            self.showAlertWithOKButton(message: kALERT_SomethingWentWrong)
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - Function -
// ----------------------------------------------------------
extension PhoneOTPVerificationVC {
    
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
        self.otpView.otpFieldsCount                     = 6
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
extension PhoneOTPVerificationVC: VPMOTPViewDelegate {
    
    func enteredOTP(otpString: String) {
        
        self.enteredOTP = otpString
        print("enteredOTP = \(otpString)")
        
        if self.enteredOTP == "" || self.enteredOTP.count < 6 {
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
