//
//  BluetoothStatusVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

protocol CaptionDelegate: AnyObject {
    func setCaption(caption: String)
}

class BluetoothStatusVC: BaseVC {

    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var txtBluetoothStatus: UITextField!
    @IBOutlet weak var lblTxtCount: UILabel!
    @IBOutlet weak var viewtxtBluetoothStatus: CustomView!
    @IBOutlet weak var btnSave: UIButton!
    
    weak var delegate: CaptionDelegate?
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        let blueViewTap = UITapGestureRecognizer(target: self, action: #selector(self.onBlueViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blueViewTap)
        
        if loginUser?.caption != nil && loginUser?.caption != "" {
            self.txtBluetoothStatus.text = loginUser?.caption
        } else {
            self.txtBluetoothStatus.text = ""
        }
        
        // Update the character count label initially
        self.updateCharacterCount()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnCancel(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnSave(_ sender: UIButton) {
        
        self.callSaveBleCaptionAPI()
    }
    
    private func updateCharacterCount(text: String? = nil) {
        
        // Calculate the character count
        let count = text?.count ?? self.txtBluetoothStatus.text?.count ?? 0
        
        // Update the character count label
        self.lblTxtCount.text = "\(count)/30"
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callSaveBleCaptionAPI() {
        
        let url = BaseURL + APIName.kSaveBleCaption
        
        let param: [String: Any] = [APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kCaption: self.txtBluetoothStatus.text ?? ""]
                
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                loginUser?.caption = self.txtBluetoothStatus.text ?? ""
                self.showAlertWithOKButton(message: msg, {
                    self.dismiss(animated: true)
                    self.delegate?.setCaption(caption: self.txtBluetoothStatus.text ?? "")
                })
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    @objc func onBlueViewTap(_ sender: UITapGestureRecognizer? = nil) {
        
        self.dismiss(animated: true)
    }
}

// ----------------------------------------------------------
//                MARK: - UITextField Delegate -
// ----------------------------------------------------------
extension BluetoothStatusVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.viewtxtBluetoothStatus.layer.borderWidth = 1.0
        self.viewtxtBluetoothStatus.layer.borderColor = UIColor.appBlue_0066FF().cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.viewtxtBluetoothStatus.layer.borderWidth = 0.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let updatedString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let updatedStringCount = (textField.text ?? "").count + string.count - range.length
        
        let characterLimit = 30
        
        if updatedStringCount <= characterLimit {
            
            // Update the character count label
            self.updateCharacterCount(text: updatedString)
        }
        
        if updatedString.isEmpty || updatedString == loginUser?.caption {
            self.btnSave.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnSave.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
            self.btnSave.isEnabled = false
        } else {
            self.btnSave.backgroundColor = UIColor.appBlue_0066FF()
            self.btnSave.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
            self.btnSave.isEnabled = true
        }
        return updatedStringCount <= characterLimit
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard
        self.txtBluetoothStatus.resignFirstResponder()
        // Return false to prevent the default behavior (i.e., hiding the keyboard)
        return false
    }
}
