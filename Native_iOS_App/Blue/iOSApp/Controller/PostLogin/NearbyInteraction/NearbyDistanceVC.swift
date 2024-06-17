//
//  NearbyDistanceVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import NearbyInteraction

class NearbyDistanceVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblNearbyUserName: UILabel!
    
    @IBOutlet weak var viewMyProfileBG: UIView!
    @IBOutlet weak var imgViewMyProfile: UIImageView!
    @IBOutlet weak var lblCurrentUserName: UILabel!
    
    @IBOutlet weak var viewNearbyUserProfileBG: UIView!
    @IBOutlet weak var imgViewNearbyUserProfile: UIImageView!
    @IBOutlet weak var lblNearbyUserBubble: UILabel!
    
    @IBOutlet weak var lblFeet: UILabel!
    
    @IBOutlet weak var viewProfileContainerBG: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var nearbyUserDetail: UserDetail?
    var nearbyUserID = ""
    private var nearbyUserDistanceInFeet: Float?
    private var alreadyNavigateToNearbyProofOfInteractionVC = false
    private var isAlreadyNotify: Bool = false
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateMyProfileUI()
        self.getNearbyUserProfileUI()
        self.updateNearbyUserDistance()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.alreadyNavigateToNearbyProofOfInteractionVC = true
        self.notifyToBrodcastMyProfile()
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnCancel(_ sender: UIButton) {
        
        let param: [String: Any] = [APIParamKey.kType: APIFlagValue.kInProcessReject,
                                    APIParamKey.kSenderId: UserLocalData.UserID,
                                    APIParamKey.kReceiver_Id: self.nearbyUserDetail?.id ?? ""]
        
        self.callBreakTheIceRequestAPI(param: param) { isSuccess, msg in
            
            if isSuccess {}
        }
        
        self.alreadyNavigateToNearbyProofOfInteractionVC = true
        self.notifyToBrodcastMyProfile()
        
        let nearbyDeclinedRequestVC = NearbyDeclinedRequestVC.instantiate(fromAppStoryboard: .NearbyInteraction)
        nearbyDeclinedRequestVC.nearbyUserDetail = self.nearbyUserDetail
        nearbyDeclinedRequestVC.isOpenFromSelfDeclined = true
        self.navigationController?.pushViewController(nearbyDeclinedRequestVC, animated: true)
    }
    
    // TODO: We are encode the UserID so we need to decode the scanned UserID and compare it with nearbyUserID then Update the nearbyUser's Distance
    @objc fileprivate func updateNearbyUserDistance() {
        
        BLEManager.shared.startScanning(services: [SERVICES.ADVERTISEMENT_DISCOVER_SERVICE_UUID]) { bleDevice, msg, isNew in
            
            if let foundUserID = bleDevice.localName ?? bleDevice.name {
                
                if foundUserID.count <= 5 {
                    
                    let decodedInt64DeviceName = UserIDEncoder().decode(encoded: foundUserID)
                    //print("decodedDeviceName: \(decodedInt64DeviceName)")
                    
                    if "\(decodedInt64DeviceName)" == self.nearbyUserID {
                        
                        print("Distance in Feet :: \(bleDevice.distanceInFeet ?? 0.0)")
                        self.nearbyUserDistanceInFeet = Float(bleDevice.distanceInFeet ?? 0.0)
                        self.lblFeet.text = "\(self.nearbyUserDistanceInFeet ?? 0.0) ft away"
                        
                        if !self.alreadyNavigateToNearbyProofOfInteractionVC {
                            self.updateBubbleUI()
                        }
                    }
                }
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    public func callNotifyInRangeUserAPI() {
        
        self.isAlreadyNotify = true
        
        let url = BaseURL + APIName.kNotifyInRangeUser
        
        let param: [String: Any] = [APIParamKey.kSenderId: UserLocalData.UserID,
                                    APIParamKey.kReceiver_Id: self.nearbyUserDetail?.id ?? ""]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                if let topVC = UIApplication.getTopViewController() {
                    
                    if !(topVC is NearbyProofOfInteractionVC) {
                        
                        let nearbyProofOfInteractionVC = NearbyProofOfInteractionVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                        nearbyProofOfInteractionVC.nearbyUserDetail = self.nearbyUserDetail
                        self.navigationController?.pushViewController(nearbyProofOfInteractionVC, animated: true)
                        
                        self.alreadyNavigateToNearbyProofOfInteractionVC = true
                    }
                }
                
            } else {
                
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func updateMyProfileUI() {
        
        if let loginIndex = arrAccount.lastIndex(where: { oneAccountData in
            return oneAccountData[APIParamKey.kUserId] as? String == UserLocalData.UserID
        }) {
            guard let profile = UserLocalData.arrOfAccountData[loginIndex][APIParamKey.kProfilePic] else { return }
            
            if let url = URL(string: profile as? String ?? "") {
                self.imgViewMyProfile.af_setImage(withURL: url, filter: nil)
            }
        }
    }
    
    private func getNearbyUserProfileUI() {
        
        if let nearbyUser = self.nearbyUserDetail {
            
            if let url = URL(string: nearbyUser.profile_img ?? "") {
                self.imgViewNearbyUserProfile.af_setImage(withURL: url, filter: nil)
            }
            
            self.lblNearbyUserBubble.text = nearbyUser.firstname ?? ""
            self.lblNearbyUserName.text = "\(nearbyUser.firstname ?? "")" + " " + "\(nearbyUser.lastname ?? "")"
            
        } else {
            
            let dbUserData = DBManager.checkUserSocialInfoExist(userID: self.nearbyUserID)
            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                
                self.nearbyUserDetail = dbUserModel
                self.getNearbyUserProfileUI()
            }
        }
    }
    
    func updateBubbleUI() {
        
        guard self.nearbyUserDistanceInFeet != nil else { return }
        let size = self.viewMyProfileBG.frame
        var movingYposition = 0.0
        
        if self.nearbyUserDistanceInFeet! <= 6.0 {
            movingYposition = UIScreen.main.bounds.width * 0.17//70
            
            if self.isAlreadyNotify == false {
                self.callNotifyInRangeUserAPI()
            }
            
        } else if self.nearbyUserDistanceInFeet! < 8.0 {
            movingYposition = UIScreen.main.bounds.width * 0.19// 80
        } else if self.nearbyUserDistanceInFeet! < 10.0 {
            movingYposition = UIScreen.main.bounds.width * 0.215// 90
        } else if self.nearbyUserDistanceInFeet! < 12.0 {
            movingYposition = UIScreen.main.bounds.width * 0.26// 110
        } else if self.nearbyUserDistanceInFeet! < 14.0 {
            movingYposition = UIScreen.main.bounds.width * 0.31// 130
        } else if self.nearbyUserDistanceInFeet! < 16.0 {
            movingYposition = UIScreen.main.bounds.width * 0.358// 150
        } else if self.nearbyUserDistanceInFeet! < 18.0 {
            movingYposition = UIScreen.main.bounds.width * 0.385// 160
        } else {
            movingYposition = UIScreen.main.bounds.width * 0.4// 80
            // movingYposition = 110
        }
        
        DispatchQueue.main.async {
            
            var xMin = 0
            var xMax = Int(self.viewProfileContainerBG.frame.width - size.size.width)
            
            if self.nearbyUserDistanceInFeet! >= 0 && self.nearbyUserDistanceInFeet! < 2 {
                xMin = xMax / 4
                xMax = xMax - xMin
            }
            
            let randomX = 4 //Int().randomNumber(range: (xMin..<xMax))
            
            let frameY: Double = size.origin.y - size.height - movingYposition
            
            let newframe = CGRect(origin: CGPoint(x: CGFloat(randomX), y: frameY), size: self.viewNearbyUserProfileBG.frame.size)
            self.viewNearbyUserProfileBG.animateTo(frame: newframe, withDuration: 2.0)
        }
    }
}
