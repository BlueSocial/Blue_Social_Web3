//
//  NearbyProofOfInteractionVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class NearbyProofOfInteractionVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewMyProfile: UIImageView!
    @IBOutlet weak var lblCurrentUserName: UILabel!
    
    @IBOutlet weak var imgViewNearbyUserProfile: UIImageView!
    @IBOutlet weak var lblNearbyUserName: UILabel!
    
    @IBOutlet weak var lblInteractionSecond: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var proofTimer: Timer?
    private var proofSecond: Int = 30
    private var currentProofSecond: Int = 0
    var nearbyUserDetail: UserDetail?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateMyProfileUI()
        self.getNearbyUserProfileUI()
        
        self.progressView.layer.cornerRadius = 5
        self.progressView.clipsToBounds = true
        
        if let gradientImage = UIImage.gradientImage(with: self.progressView.frame, colors: [AppTheme.RightBlue.cgColor, AppTheme.LeftBlue.cgColor], isHorizontal: true) {
            self.progressView.progressImage = gradientImage
        }
        
        self.progressView.borderWidth = 1.0
        self.progressView.borderColor = UIColor.white
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.proofTimer?.invalidate()
            self.proofTimer = nil
            self.proofTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onProofTimerChange), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.notifyToBrodcastMyProfile()
        self.proofTimer?.invalidate()
        self.proofTimer = nil
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
        
        self.proofTimer?.invalidate()
        self.proofTimer = nil
        
        self.notifyToBrodcastMyProfile()
        self.proofTimer?.invalidate()
        self.proofTimer = nil
        
        //        var isVCFound = false      
        //        for vc in self.navigationController?.viewControllers ?? [UIViewController]() {
        //            if vc is MainTabbarController {
        //                isVCFound = true
        //                self.navigationController?.popToViewController(vc, animated: true)
        //                break
        //            }
        //        }
        //        if !isVCFound {
        //            self.navigationController?.popViewController(animated: true)
        //        }
        //        return
        
        let nearbyDeclinedRequestVC = NearbyDeclinedRequestVC.instantiate(fromAppStoryboard: .NearbyInteraction)
        nearbyDeclinedRequestVC.nearbyUserDetail = self.nearbyUserDetail
        nearbyDeclinedRequestVC.isOpenFromSelfDeclined = true
        self.navigationController?.pushViewController(nearbyDeclinedRequestVC, animated: true)
    }
    
    @objc func onProofTimerChange(timer: Timer) {
        
        DispatchQueue.main.async {
            self.currentProofSecond += 1
            self.lblInteractionSecond.text = "\(self.currentProofSecond)"
            
            self.progressView.progress = Float( CGFloat(self.currentProofSecond) / CGFloat(self.proofSecond))
            if self.currentProofSecond == self.proofSecond {
                self.proofTimer?.invalidate()
                self.callProofOfInteractionAPI(status: true)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    public func callProofOfInteractionAPI(status: Bool) {
        
        let url = BaseURL + APIName.kProofOfInteraction
        
        let lat = LocationManager.shared.locationManager?.location?.coordinate.latitude ?? 0.0
        let lng = LocationManager.shared.locationManager?.location?.coordinate.longitude ?? 0.0
        
        print("\(self) lat :: \(lat)")
        print("\(self) lng :: \(lng)")
        
        let randomInt = Int.random(in: 5 ..< 20)
        print("Random Number form 5 to 20 range :: \(randomInt)")
        
        let param: [String: Any] = [APIParamKey.kSenderId: UserLocalData.UserID,
                                    APIParamKey.kReceiver_Id: self.nearbyUserDetail?.id ?? "",
                                    APIParamKey.kDuration: self.currentProofSecond,
                                    APIParamKey.kStatus: status ? "SUCCESS" : "FAILURE",
                                    APIParamKey.kLat: lat,
                                    APIParamKey.kLng: lng,
                                    APIParamKey.kBST: "\(randomInt)"]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                print("proofOfInteraction isSuccess msg: \(msg)")
                self.proofTimer?.invalidate()
                self.proofTimer = nil
                
                let nearbyInteractionValidatedVC = NearbyInteractionValidatedVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                nearbyInteractionValidatedVC.nearbyUserDetail = self.nearbyUserDetail
                nearbyInteractionValidatedVC.isSuccess = status
                nearbyInteractionValidatedVC.interactionDuration  = self.currentProofSecond
                nearbyInteractionValidatedVC.BSTValue = "\(randomInt)"
                self.currentProofSecond = 0
                self.navigationController?.pushViewController(nearbyInteractionValidatedVC, animated: true)
                
            } else {
                
                self.currentProofSecond = 0
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
            
            self.lblCurrentUserName.text = "Me"
        }
    }
    
    private func getNearbyUserProfileUI() {
        
        if let nearbyUser = self.nearbyUserDetail {
            
            if let url = URL(string: nearbyUser.profile_img ?? "") {
                self.imgViewNearbyUserProfile.af_setImage(withURL: url, filter: nil)
            }
            
            self.lblNearbyUserName.text = "\(nearbyUser.firstname ?? "")"
        }
    }
}
