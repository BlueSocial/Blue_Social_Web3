//
//  NearbyRequestVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import NearbyInteraction

class NearbyRequestVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewNearbyUserProfile: UIImageView!
    @IBOutlet weak var lblNearbyUserName: UILabel!
    
    @IBOutlet weak var cvInterest: UICollectionView!
    @IBOutlet weak var lblInteractionDetail: UILabel!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    
    @IBOutlet weak var lblTitleInterest: UILabel!
    @IBOutlet weak var heightCVInterest: NSLayoutConstraint!
    @IBOutlet weak var widthCVInterest: NSLayoutConstraint!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var navigationScreen = NavigationScreen.currentUserProfile
    var nearbyUserID = ""
    var receiverBLEAds = ""
    var currentUserDetail: UserDetail?
    var nearbyUserDetail: UserDetail?
    var isCurrentUserAccept = true
    var uwbToken = ""
    var isU1ChipAvailable = "0"
    private var arrInterestTopic: [User_Interest] = []
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cvInterest.register(InterestTopicCVCell.nib, forCellWithReuseIdentifier: InterestTopicCVCell.identifier)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.cvInterest.frame.size.width, height: 40)
        self.cvInterest.collectionViewLayout = flowLayout
        
        self.setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.cvInterest.reloadData()
        self.view.layoutIfNeeded()
        self.heightCVInterest.constant = self.cvInterest.contentSize.height
        self.widthCVInterest.constant = self.cvInterest.contentSize.width
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
                                    APIParamKey.kReceiver_Id: self.nearbyUserID]
        
        self.callBreakTheIceRequestAPI(param: param) { isSuccess, msg in
            
            if isSuccess {}
        }
        
        let nearbyDeclinedRequestVC = NearbyDeclinedRequestVC.instantiate(fromAppStoryboard: .NearbyInteraction)
        nearbyDeclinedRequestVC.nearbyUserDetail = self.nearbyUserDetail
        nearbyDeclinedRequestVC.isOpenFromSelfDeclined = true
        self.navigationController?.pushViewController(nearbyDeclinedRequestVC, animated: true)
        
        //self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnAccept(_ sender: UIButton) {
        
        print("onBtnAccept - uwbToken :: \(self.uwbToken)")
        
        var param: [String: Any] = [
            APIParamKey.kType: APIFlagValue.kAccept,
            APIParamKey.kSenderId: UserLocalData.UserID,
            APIParamKey.kReceiver_Id: self.nearbyUserID,
            APIParamKey.kuwb_token: self.uwbToken
        ]
        
        if #available(iOS 14.0, *), NISession.isSupported {
            param[APIParamKey.kis_u1_chip_available] = "1"
        } else {
            param[APIParamKey.kis_u1_chip_available] = "0"
        }
        
        self.callBreakTheIceRequestAPI(param: param) { isSuccess, msg in
            
            if isSuccess {
                
                DispatchQueue.main.async {
                    
                    if self.isU1ChipAvailable == "1", #available(iOS 14.0, *), NISession.isSupported {
                        
                        print("::: U1Chip supported :::")
                        let nearbyDirectionVC = NearbyDirectionVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                        nearbyDirectionVC.nearbyUserDetail = self.nearbyUserDetail
                        nearbyDirectionVC.nearbyUserID = self.nearbyUserID
                        nearbyDirectionVC.uwbToken = self.uwbToken
                        self.navigationController?.pushViewController(nearbyDirectionVC, animated: true)
                        
                    } else {
                        
                        print("::: U1Chip is not supported | Fallback on earlier versions | Android Device :::")
                        let nearbyDistanceVC = NearbyDistanceVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                        nearbyDistanceVC.nearbyUserID = self.nearbyUserID
                        self.navigationController?.pushViewController(nearbyDistanceVC, animated: true)
                    }
                }
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        let dbUserData = DBManager.checkUserSocialInfoExist(userID: nearbyUserID)
        
        if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
            self.nearbyUserDetail = dbUserModel
            
            DispatchQueue.main.async {
                
                if let nearbyUser = self.nearbyUserDetail {
                    
                    if let url = URL(string: nearbyUser.profile_img ?? "") {
                        self.imgViewNearbyUserProfile.af_setImage(withURL: url, filter: nil)
                    }
                    
                    let firstname = "\(nearbyUser.firstname ?? "")"
                    self.lblNearbyUserName.text = firstname
                    self.lblInteractionDetail.text = "Would you like to be social with \(firstname)?"
                    
                    self.arrInterestTopic = nearbyUser.userInterest ?? []
                    
                    if self.arrInterestTopic.count == 0 {
                        self.cvInterest.isHidden = true
                        self.lblTitleInterest.isHidden = true
                    }
                }
            }
            
        } else {
            
            self.showCustomLoader()
            self.callGetUserInfoAPI(nearByUserID: self.nearbyUserID) { isSuccess, response in
                self.hideCustomLoader()
                
                if let getInfoAPIResponse = response {
                    
                    self.setUserSocialInfoInDB(userID: self.nearbyUserID, userJSON: getInfoAPIResponse.toJSONString()!)
                    
                    DispatchQueue.main.async {
                        
                        if let url = URL(string: getInfoAPIResponse.profile_img ?? "") {
                            self.imgViewNearbyUserProfile.af_setImage(withURL: url, filter: nil)
                        }
                        
                        let firstname = "\(getInfoAPIResponse.firstname ?? "")"
                        self.lblNearbyUserName.text = firstname
                        self.lblInteractionDetail.text = "Would you like to be social with \(firstname)?"
                        
                        self.arrInterestTopic = getInfoAPIResponse.userInterest ?? []
                        
                        if self.arrInterestTopic.count == 0 {
                            self.cvInterest.isHidden = true
                            self.lblTitleInterest.isHidden = true
                        }
                    }
                }
            }
        }
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension NearbyRequestVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // return self.arrInterestTopic.count
        
        if self.arrInterestTopic.count <= 4 {
            
            var countByTwo: Double = Double(self.arrInterestTopic.count) / Double(2.0)
            countByTwo.round(.up)
            print("numberOfItemsInSection: \(Int(countByTwo))")
            return Int(countByTwo)
            
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.cvInterest.dequeueReusableCell(withReuseIdentifier: InterestTopicCVCell.identifier, for: indexPath) as? InterestTopicCVCell {
            
            guard self.arrInterestTopic.indices.contains(indexPath.row * 2) else { return cell }
            let obj1 = self.arrInterestTopic[indexPath.row * 2]
            print("obj1: \(obj1)")
            cell.lblInterest1.text = obj1.name
            
            if self.arrInterestTopic.count == (indexPath.row * 2) + 1 {
                cell.outerViewLbl2.isHidden = true
                cell.centerInnerViewLbl1.priority = UILayoutPriority(rawValue: 60)
                cell.trailingInnerViewLbl1.priority = UILayoutPriority(rawValue: 50)
            }
            
            guard self.arrInterestTopic.indices.contains((indexPath.row * 2) + 1) else { return cell }
            let obj2 = self.arrInterestTopic[(indexPath.row * 2) + 1]
            print("obj2: \(obj2)")
            cell.lblInterest2.text = obj2.name
            cell.centerInnerViewLbl1.priority = UILayoutPriority(rawValue: 50)
            cell.trailingInnerViewLbl1.priority = UILayoutPriority(rawValue: 60)
            return cell
        }
        
        return UICollectionViewCell()
    }
}
