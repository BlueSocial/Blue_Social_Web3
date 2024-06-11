//
//  ExchangeContactVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class ExchangeContactVC: BaseVC {

    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var lblExchangeInfo: UILabel!
    @IBOutlet weak var lblBST: UILabel!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    internal var navigationScreen = NavigationScreen.none
    internal var receiver_id = ""
    internal var firstName = ""
    internal var randomBST = ""
    internal var isFromNotificationList = false
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        let blueViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blueViewTap)
        
        if self.navigationScreen == .QRScan {
            
            self.lblExchangeInfo.text = "You earned tokens for exchanging your contact information with \(self.firstName)."
            
        } else if self.navigationScreen == .notification {
            
            self.lblExchangeInfo.text = "You earned tokens from \(self.firstName) exchanging their contact information with you."
        }
        
        self.lblBST.text = self.randomBST + " BLUE"
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @objc func blurViewTap(_ sender: UITapGestureRecognizer? = nil) {
        
        //self.dismiss(animated: true)
    }
    
    @IBAction func onBtnClose(_ sender: UIButton) {
        
        if self.isFromNotificationList {
            self.dismiss(animated: true)
            
        } else {
            self.callAddInteractionBstAPI()
        }
    }
    
    @IBAction func onBtnContinue(_ sender: UIButton) {
        
        if self.isFromNotificationList {
            self.dismiss(animated: true)
            
        } else {
            self.callAddInteractionBstAPI()
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callAddInteractionBstAPI() {
        
        let url = BaseURL + APIName.kAddInteractionBst
        
        print("BST Sender UserID: \(UserLocalData.UserID)")
        print("BST Receiver UserID: \(self.receiver_id)")

        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kExchangeTokenReceived,
                                    APIParamKey.kUser_Id: UserLocalData.UserID,
                                    APIParamKey.kReceiver_Id: self.receiver_id,
                                    APIParamKey.kBST: Int(self.randomBST) ?? 0,
                                    APIParamKey.kCurrentTimestamp: self.getCurrentUTCTimestamp()]

        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess, let interactionBST = response?.interactionBST {

                let totalBST = (loginUser?.totalBST ?? 0) + (Int(self.randomBST) ?? 0)
                loginUser?.totalBST = totalBST
                
                if loginUser != nil {
                    if loginUser?.user_mode == "0" {
                        self.setUserSocialInfoInDB(userID: UserLocalData.UserID, userJSON: loginUser!.toJSONString()!)
                    }
                }
            }
            
            self.dismiss(animated: true)
        }
    }
    
    private func updateDataIntoDB(individualInteraction: String) {
        
        if DBManager.isIndividualProofInteraction(userID: UserLocalData.UserID) {
            
            // UPDATE
            if DBManager.setIndividualProofInteraction(userID: UserLocalData.UserID, requestBody: individualInteraction) {
                print("UPDATE API Response in Individual Proof Interaction Table Successfully")
            }
            
        } else {
            
            // INSERT
            if DBManager.insertIndividualProofInteraction(userID: UserLocalData.UserID, requestBody: individualInteraction) {
                print("INSERT API Response in Individual Proof Interaction Table Successfully")
            }
        }
    }
}
