//
//  NearbyWaitingApprovalVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import NearbyInteraction

class NearbyWaitingApprovalVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewMyProfile: UIImageView!
    @IBOutlet weak var lblCurrentUserName: UILabel!
    
    @IBOutlet weak var imgViewNearbyUserProfile: UIImageView!
    @IBOutlet weak var lblNearbyUserName: UILabel!
    
    @IBOutlet weak var lblInteractionDetail: UILabel!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var nearbyUserDetail: UserDetail?
    
    typealias completionBlock = ((Bool) -> Void)
    fileprivate var completion: completionBlock?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnCancel(_ sender: UIButton) {
        
        let param: [String: Any] = [APIParamKey.kType: APIFlagValue.kReject,
                                    APIParamKey.kSenderId: UserLocalData.UserID,
                                    APIParamKey.kReceiver_Id: self.nearbyUserDetail?.id ?? ""]
        
        self.callBreakTheIceRequestAPI(param: param) { isSuccess, msg in
            
            if isSuccess {}
        }
        
        if self.completion != nil {
            self.completion!(false)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        if let loginIndex = arrAccount.lastIndex(where: { oneAccountData in
            return oneAccountData[APIParamKey.kUserId] as? String == UserLocalData.UserID
        }) {
            guard let profile = UserLocalData.arrOfAccountData[loginIndex][APIParamKey.kProfilePic] else { return }
            
            if let url = URL(string: profile as? String ?? "") {
                self.imgViewMyProfile.af_setImage(withURL: url, filter: nil)
            }
        }
        
        if let nearbyUser = self.nearbyUserDetail {
            
            if let url = URL(string: nearbyUser.profile_img ?? "") {
                self.imgViewNearbyUserProfile.af_setImage(withURL: url, filter: nil)
            }
            
            self.lblNearbyUserName.text = "\(nearbyUser.firstname ?? "")"
            self.lblInteractionDetail.text = "You sent \(nearbyUser.firstname ?? "") a direct notification. Waiting for interaction to be accepted to be social"
        }
    }
    
    func waitingForSignal(mycompletion: @escaping completionBlock) {
        self.completion = mycompletion
    }
}
