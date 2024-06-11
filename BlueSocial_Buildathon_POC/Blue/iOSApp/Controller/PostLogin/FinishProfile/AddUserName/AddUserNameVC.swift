//
//  AddUserNameVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddUserNameVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var lblErrorUsername: UILabel!
    
    @IBOutlet weak var btnContinue: CustomButton!
    @IBOutlet weak var middleView: UIView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var timer: Timer?
    private var isUsernameAvailable: Bool = false
    //    private var initialContinueButtonFrame: CGRect!
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblErrorUsername.isHidden = true
        self.txtUsername.addTarget(self, action: #selector(onUsernameChange(_:)), for: .editingChanged)
        
        self.updateContinueButtonState()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        // Check if MainTabbarController is in the navigation stack
        if let mainTabbarController = navigationController?.viewControllers.first(where: { $0 is MainTabbarController }) as? MainTabbarController {
            // MainTabbarController is in the stack, pop to it
            navigationController?.popToViewController(mainTabbarController, animated: true)
        } else {
            self.setRootViewController()
        }
    }
    
    private func updateContinueButtonState() {
        
        if self.isUsernameAvailable {
            
            self.btnContinue.backgroundColor = UIColor.appBlue_0066FF()
            self.btnContinue.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
            self.btnContinue.isUserInteractionEnabled = true
            
        } else {
            
            self.btnContinue.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnContinue.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
            self.btnContinue.isUserInteractionEnabled = false
        }
    }
    
    @objc func onUsernameChange(_ textField: UITextField) {
        
        let updatedString = textField.text
        print("UpdatedString :: \(updatedString ?? "")")
        
        let textString = self.txtUsername.text!.replacingOccurrences(of: " ", with: "_")
        self.txtUsername.text = textString
        self.timer?.invalidate()
        
        if updatedString?.count ?? 0 > 3 {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                self.callCheckUserNameExistAPI()
            })
            
        } else {
            
            self.timer?.invalidate()
            
            self.isUsernameAvailable = false
            self.txtUsername.shake()
            
            self.lblErrorUsername.isHidden = false
            self.lblErrorUsername.text = ALERT_UserNameMin
            
            self.btnContinue.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnContinue.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
            self.btnContinue.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func onBtnContinue(_ sender: UIButton) {
        
        self.callUpdateUsernameAPI()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callCheckUserNameExistAPI() {
        
        let url = BaseURL + APIName.kCheckUsername
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kCheckUsername,
                                    APIParamKey.kUsername: self.txtUsername.text!.trime()]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            
            if isSucess {
                
                self.isUsernameAvailable = true
                
                self.lblErrorUsername.isHidden = true
                self.lblErrorUsername.text = ""
                
            } else {
                
                self.isUsernameAvailable = false
                self.txtUsername.shake()
                
                self.lblErrorUsername.isHidden = false
                self.lblErrorUsername.text = msg
            }
            
            // Delay the button state update to avoid keyboard dismissal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateContinueButtonState()
            }
        }
    }
    
    private func callUpdateUsernameAPI() {
        
        let url = BaseURL + APIName.kUpdateUsername
        
        let param: [String: Any] = [APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kUsername: self.txtUsername.text!.trime(),
                                    APIParamKey.kIsProfileCompleted: "1"]
        
        UserLocalData.userName = self.txtUsername.text ?? ""
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            
            if isSucess {
                
                loginUser?.is_profile_completed = "1"
                
                if let topVC = UIApplication.getTopViewController() {
                    
                    let addPhotoVC = AddPhotoVC.instantiate(fromAppStoryboard: .Login)
                    topVC.navigationController?.pushViewController(addPhotoVC, animated: true)
                }
                
            } else {
                
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
}

// ----------------------------------------------------------
//                       MARK: - UITextFieldDelegate -
// ----------------------------------------------------------
extension AddUserNameVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtUsername:
                break
                
            default:
                break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtUsername:
                break
                
            default:
                break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Define the allowed characters using a regular expression
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-.")
        
        // Check if the entered string contains only allowed characters
        let enteredCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: enteredCharacterSet)
    }
}
