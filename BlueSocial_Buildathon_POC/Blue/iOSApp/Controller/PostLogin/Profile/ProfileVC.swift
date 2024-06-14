//
//  ProfileVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import CoreLocation
import MapKit
import MessageUI
import ContactsUI
import NearbyInteraction
import GoogleMaps
import DynamicBlurView

protocol DiscoverCaptionDelegate: AnyObject {
    func setCaptionInDiscover(caption: String)
}

class ProfileVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var imgViewTorus: UIImageView!
    @IBOutlet weak var imgViewConePurple: UIImageView!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var lblCompanyOrUniversityName: UILabel!
    @IBOutlet weak var imgViewBlurCompanyOrUniversityName: UIImageView!
    @IBOutlet weak var imgViewCube: UIImageView!
    @IBOutlet weak var imgViewTorus2: UIImageView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var imgViewAddEditProfile: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgViewBlurUserName: UIImageView!
    @IBOutlet weak var btnBluetoothStatus: UIButton!
    @IBOutlet weak var imgViewBlurBluetoothStatus: UIImageView!
    @IBOutlet weak var imgViewCheese: UIImageView!
    @IBOutlet weak var imgViewCubePurple: UIImageView!
    @IBOutlet weak var lblUserProfileViewCount: UILabel!
    @IBOutlet weak var lblLinkClicksCount: UILabel!
    @IBOutlet weak var lblUserInteractionCount: UILabel!
    @IBOutlet weak var btnMyWallet: UIButton!
    @IBOutlet weak var topBtnMyWallet: NSLayoutConstraint!
    @IBOutlet weak var bottomBtnMyWallet: NSLayoutConstraint!
    @IBOutlet weak var heightBtnMyWallet: NSLayoutConstraint!
    @IBOutlet weak var imgViewUserToken: UIImageView!
    @IBOutlet weak var btnPro: UIButton!
    @IBOutlet weak var stackViewLinkClick: UIStackView!
    @IBOutlet weak var imgViewConeBlue: UIImageView!
    @IBOutlet weak var imgViewRock: UIImageView!
    @IBOutlet weak var lblUserToken: UILabel!
    @IBOutlet weak var lblToken: UILabel!
    
    @IBOutlet weak var viewEditProfile: UIView!
    @IBOutlet weak var imgViewEditProfile: UIImageView!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var lblEditProfile: UILabel!
    
    @IBOutlet weak var viewShareProfile: UIView!
    @IBOutlet weak var imgViewShare: UIImageView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblShare: UILabel!
    
    @IBOutlet weak var viewQRCode: UIView!
    @IBOutlet weak var imgViewQRCode: UIImageView!
    @IBOutlet weak var lblQRCode: UILabel!
    @IBOutlet weak var btnQRCode: UIButton!
    
    @IBOutlet weak var viewAboutMe: UIView!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var stackViewUniversity: UIStackView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var cvChip: UICollectionView!
    @IBOutlet weak var heightCVChip: NSLayoutConstraint!
    @IBOutlet weak var btnShowAll: UIButton!
    
    @IBOutlet weak var tblSocialNetwork: UITableView!
    @IBOutlet weak var heightTblSocialNetwork: NSLayoutConstraint!
    @IBOutlet weak var lblNoSocialNetwork: UILabel!
    @IBOutlet weak var viewNoNetwork: UIView!
    
    @IBOutlet weak var stackViewMap: UIStackView!
    @IBOutlet weak var lblResumeTitle: UILabel!
    @IBOutlet weak var lblNoDocument: UILabel!
    @IBOutlet weak var stackViewResume: UIStackView!
    @IBOutlet weak var lblResume: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnBreakTheIce: UIButton!
    @IBOutlet weak var heightStackViewBreakTheIce: NSLayoutConstraint!
    
    @IBOutlet weak var topBGView: CustomView!
    
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var viewBlur1: UIView!
    @IBOutlet weak var imgViewLocked: UIImageView!
    
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var topSVEditProfile: NSLayoutConstraint!
    @IBOutlet weak var heightSVEditProfile: NSLayoutConstraint!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    internal var navigationScreen = NavigationScreen.currentUserProfile
    
    private var socialDetail: UserDetail?
    private var businessDetail: UserDetail?
    private var arrSocialNetwork = [Social_Network_List]()
    
    private var arrInterestTopic = [User_Interest]()
    private var labelWidth = 0.0
    private let spacing: CGFloat = 8
    private let padding: CGFloat = 16
    private var showAllItems = false
    
    internal var deviceScanHistory: DeviceScanHistory?
    internal var receiver_id = ""
    
    var imgPP = UIImage(named: "ic_user_placeholer")
    var shareUserProfile: URL?
    
    private var arrCustomInterestTopic: [User_Interest]? = []
    internal var nearByUserId = ""
    internal var nearByUserDetail = UserDetail()
    typealias GetCurrentUserUpdate = (UserDetail) -> Void
    private var getCurrentUserUpdate: GetCurrentUserUpdate?
    internal var slug: String = ""
    var popEvent: (() -> Void)?
    internal var shouldNotCallAPI: Bool = false
    var uwbToken = ""
    private var businessFirstname = ""
    private var businessLastname = ""
    var isUser_ReferalConnect: Bool = false
    
    let marker = GMSMarker()
    
    internal var user_mode: String?
    internal var subscriptionStatus: String?
    
    internal var addNoteCallback: ((String, [String]) -> Void)?
    internal var unlockProfileCallback: ((MissedOpportunityList) -> Void)?
    
    private var userNote = ""
    private var arrLabel: [String] = []
    
    weak var delegate: DiscoverCaptionDelegate?
    
    internal var objMissedOpportunityList: MissedOpportunityList?
    internal var selectedButton = "Locked"
    internal var timeRemainingToUnlockProfile = ""
    private var isProfileUnlockedSuccessfully: Bool = false
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        let imgProfileTap = UITapGestureRecognizer(target: self, action: #selector(self.imgProfileTap(_:)))
        self.imgViewProfile.addGestureRecognizer(imgProfileTap)
        self.imgViewProfile.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.bringSubviewToFront(self.stackViewLinkClick)
        self.setupCVTVHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUserProfileUI()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        if self.navigationScreen == .currentUserProfile || self.navigationScreen == .switchProfile {
            
            if let caption = self.btnBluetoothStatus.title(for: .normal) {
                print("Button title: \(caption)")
                self.delegate?.setCaptionInDiscover(caption: caption)
            } else {
                print("Button does not have a title set.")
            }
            
        } else if self.navigationScreen == .businessCardScan {
            
            var isVCFound = false
            for vc in self.navigationController?.viewControllers ?? [UIViewController]() {
                if vc is MainTabbarController {
                    isVCFound = true
                    
                    // Use a custom transition
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.type = CATransitionType.reveal
                    transition.subtype = CATransitionSubtype.fromBottom
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
            
            if !isVCFound {
                
                let tabbar = MainTabbarController.instantiate(fromAppStoryboard: .Discover)
                tabbar.selectedIndex = 1 // Select the desired tab index
                
                // Set the tab bar controller as the root view controller
                UIApplication.shared.windows.first?.rootViewController = tabbar
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            
        } else if self.navigationScreen == .QRScan {
            
            popEvent?()
            
        } else {
            
            if self.getCurrentUserUpdate != nil {
                
                if self.nearByUserDetail.user_mode == "0" || self.nearByUserDetail.subscriptionStatus == "0" {
                    
                    if let social = self.socialDetail {
                        self.getCurrentUserUpdate!(social)
                    }
                    
                } else {
                    
                    if let business = self.businessDetail {
                        self.getCurrentUserUpdate!(business)
                    }
                }
            }
        }
        
        if let callback = self.addNoteCallback {
            callback(self.deviceScanHistory?.notes ?? "", self.deviceScanHistory?.label ?? [])
        }
        
        // Use a custom transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onBtnMenu(_ sender: UIButton) { // Work as share Button when open Profile screen from Interactions List and .discover (NearByUser)
        
        switch self.navigationScreen {
                
            case .currentUserProfile, .switchProfile:
                
                let menuVC = MenuVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                menuVC.modalTransitionStyle = .crossDissolve
                menuVC.modalPresentationStyle = .overCurrentContext
                menuVC.currentUserDetail = self.socialDetail
                menuVC.profileURL = self.shareUserProfile
                
                menuVC.switchProfileCallback = {
                    self.navigationScreen = .switchProfile
                    self.viewWillAppear(false)
                }
                
                self.present(menuVC, animated: true, completion: nil)
                break
                
            case .discover, .deviceHistory, .notification, .map:
                
                if !self.isUser_ReferalConnect {
                    
                    if UserLocalData.userMode == "0" {
                        
                        let linkToShare = URL(string: self.socialDetail?.unique_url ?? "")!
                        let activityViewController = UIActivityViewController(activityItems: [linkToShare], applicationActivities: nil)
                        self.present(activityViewController, animated: true, completion: nil)
                        
                    } else {
                        
                        let linkToShare = URL(string: self.businessDetail?.unique_url ?? "")!
                        let activityViewController = UIActivityViewController(activityItems: [linkToShare], applicationActivities: nil)
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                }
                break
                
            default:
                break
        }
    }
    
    @IBAction func onBtnBluetoothStatus(_ sender: UIButton) {
        
        if self.navigationScreen == .currentUserProfile || self.navigationScreen == .switchProfile {
            let bluetoothStatusVC = BluetoothStatusVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            bluetoothStatusVC.delegate = self
            bluetoothStatusVC.modalTransitionStyle = .crossDissolve
            bluetoothStatusVC.modalPresentationStyle = .overCurrentContext
            self.present(bluetoothStatusVC, animated: true)
        }
    }
    
    @IBAction func onBtnMyWallet(_ sender: UIButton) {
        
        let walletVC = WalletVC.instantiate(fromAppStoryboard: .Discover)
        self.navigationController?.pushViewController(walletVC, animated: true)
    }
    
    @IBAction func onBtnEditProfile(_ sender: UIButton) {
        
        if self.lblEditProfile.text == "Add to Contact" {
            
            self.addContectData()
            
        } else {
            
            let editProfileVC = EditProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            self.navigationController?.pushViewController(editProfileVC, animated: true)
        }
    }
    
    @IBAction func onBtnShareProfile(_ sender: UIButton) {
        
        switch self.navigationScreen {
                
            case .currentUserProfile, .discover, .QRScan, .switchProfile, .dynamicLink, .businessCardScan:
                
                if self.socialDetail?.user_mode == "0" || self.socialDetail?.subscriptionStatus == "0" {
                    
                    if let linkToShare = URL(string: self.socialDetail?.unique_url ?? "") {
                        let activityViewController = UIActivityViewController(activityItems: [linkToShare], applicationActivities: nil)
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                    
                } else {
                    
                    if let linkToShare = URL(string: self.businessDetail?.unique_url ?? "") {
                        let activityViewController = UIActivityViewController(activityItems: [linkToShare], applicationActivities: nil)
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                }
                break
                
            case .deviceHistory, .notification, .map:
                
                let addNoteVC = AddNoteVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                addNoteVC.modalTransitionStyle = .crossDissolve
                addNoteVC.modalPresentationStyle = .overCurrentContext
                
                addNoteVC.addNoteCallback = { (txtNote, arrLabel, msg) in
                    self.showAlertWithOKButton(message: msg)
                    
                    self.deviceScanHistory?.notes = txtNote
                    self.deviceScanHistory?.label = arrLabel
                    
                    self.userNote = txtNote
                    self.arrLabel = arrLabel
                }
                
                if self.navigationScreen == .notification {
                    addNoteVC.receiverId = self.receiver_id
                    addNoteVC.userNote = self.userNote
                    addNoteVC.arrLabel = self.arrLabel
                    
                } else if self.navigationScreen == .deviceHistory {
                    addNoteVC.receiverId = self.deviceScanHistory?.receiver_id ?? ""
                    addNoteVC.userNote = self.deviceScanHistory?.notes ?? ""
                    addNoteVC.arrLabel = self.deviceScanHistory?.label ?? []
                }
                self.navigationController?.present(addNoteVC, animated: true)
                break
                
            default:
                break
        }
    }
    
    @IBAction func onBtnQRCode(_ sender: UIButton) {
        // Work as QRCode when open Profile screen from CurrentUserProfile (DiscoverVC - onBtnMyProfile)
        // Work as SendToken when open Profile screen from NearByUser (DiscoverVC - onBtnNearByBubble) and Interaction List
        
        switch self.navigationScreen {
                
            case .currentUserProfile, .switchProfile:
                let myQRCodeVC = MyQRCodeVC.instantiate(fromAppStoryboard: .Discover)
                myQRCodeVC.navigationScreen = .currentUserProfile
                self.navigationController?.pushViewController(myQRCodeVC, animated: true)
                break
                
            default:
                break
        }
    }
    
    @IBAction func onBtnShowAll(_ sender: UIButton) {
        self.showAllItems.toggle()
        
        let buttonText = showAllItems ? "Show Less" : "Show All"
        sender.setTitle(buttonText, for: .normal)
        
        self.cvChip.reloadData()
        
        self.heightCVChip.constant = calculateCollectionViewHeight()
    }
    
    @IBAction func onBtnViews(_ sender: UIButton) {
        
        if self.navigationScreen == .currentUserProfile || self.navigationScreen == .switchProfile {
            
            let insightMainVC = InsightMainVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            //insightMainVC.shareProfile = self.shareUserProfile
            self.navigationController?.pushViewController(insightMainVC, animated: true)
        }
    }
    
    @IBAction func onBtnLinkClicks(_ sender: UIButton) {
        
        if self.navigationScreen == .currentUserProfile || self.navigationScreen == .switchProfile {
            
            let insightMainVC = InsightMainVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            //insightMainVC.shareProfile = self.shareUserProfile
            self.navigationController?.pushViewController(insightMainVC, animated: true)
        }
    }
    
    @IBAction func onBtnInteractions(_ sender: UIButton) {
        
        if self.navigationScreen == .currentUserProfile || self.navigationScreen == .switchProfile {
            
            let insightMainVC = InsightMainVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            //insightMainVC.isFromInteractions = true
            //insightMainVC.shareProfile = self.shareUserProfile
            self.navigationController?.pushViewController(insightMainVC, animated: true)
        }
    }
    
    @IBAction func onBtnBreakTheIce(_ sender: UIButton) {
        
        if self.navigationScreen == .QRScan || self.navigationScreen == .dynamicLink {
            
            var receiverId = ""
            var firstName = ""
            
            if let id = self.socialDetail?.id {
                receiverId = id
                firstName = self.socialDetail?.firstname ?? (self.socialDetail?.name ?? "")
            } else {
                receiverId = self.businessDetail?.id ?? ""
                firstName = self.businessDetail?.business_firstName ?? (self.businessDetail?.name ?? "")
            }
            
            // here Call API to Exchange Contact
            let param: [String: Any] = [
                APIParamKey.kSenderId: UserLocalData.UserID,
                APIParamKey.kReceiver_Id: receiverId,
                APIParamKey.kLat: LocationManager.shared.locationManager?.location?.coordinate.latitude ?? 0.0,
                APIParamKey.kLng: LocationManager.shared.locationManager?.location?.coordinate.longitude ?? 0.0,
                APIParamKey.kCurrentTimestamp: self.getCurrentUTCTimestamp()
            ]
            
            self.callNotifyConnectUserAPI(param: param) { isSuccess, msg in
                
                if isSuccess {
                    
                    self.btnBreakTheIce.setTitle("Exchanged Successfully", for: .normal)
                    self.btnBreakTheIce.backgroundColor = UIColor.appGreen_14CD14()
                    self.btnBreakTheIce.isUserInteractionEnabled = false
                    
                    let randomInt = Int.random(in: 5 ..< 20)
                    
                    let exchangeContactVC = ExchangeContactVC.instantiate(fromAppStoryboard: .Discover)
                    exchangeContactVC.modalTransitionStyle = .crossDissolve
                    exchangeContactVC.modalPresentationStyle = .overCurrentContext
                    
                    exchangeContactVC.navigationScreen = .QRScan
                    exchangeContactVC.receiver_id = receiverId
                    exchangeContactVC.firstName = firstName
                    exchangeContactVC.randomBST = "\(randomInt)"
                    
                    self.present(exchangeContactVC, animated: true, completion: nil)
                    
                } else {
                    
                    //self.showAlertWithOKButton(message: msg ?? "Already Exchanged")
                    self.btnBreakTheIce.setTitle(msg ?? "Already Exchanged", for: .normal)
                    self.btnBreakTheIce.backgroundColor = UIColor.appGreen_14CD14()
                    self.btnBreakTheIce.isUserInteractionEnabled = false
                }
            }
            
        } else {
            
            if UserLocalData.breakTheICE {
                // If Checkbox-Do not show again checked in BreakTheIcePopupVC // onBtnDoNotShowAgainBreakTheICE
                
                print("onBtnBreakTheIce - uwbToken :: \(self.uwbToken)")
                
                var param: [String: Any] = [
                    APIParamKey.kType: APIFlagValue.kSent,
                    APIParamKey.kSenderId: UserLocalData.UserID,
                    APIParamKey.kReceiver_Id: self.nearByUserId,
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
                            self.waitingForNearByApprove()
                        }
                    }
                }
                
            } else {
                
                let breakTheIcePopupVC = BreakTheIcePopupVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                breakTheIcePopupVC.nearbyUserID = self.nearByUserId
                
                breakTheIcePopupVC.breakTheICEButtonTapped { isUserBreak in
                    
                    if isUserBreak {
                        
                        self.btnBreakTheIce.isUserInteractionEnabled = false
                        DispatchQueue.main.async {
                            self.waitingForNearByApprove()
                        }
                    }
                }
                breakTheIcePopupVC.view.backgroundColor = UIColor.clear
                
                //breakTheIcePopupVC.modalPresentationStyle = .overCurrentContext
                //breakTheIcePopupVC.modalTransitionStyle = .crossDissolve
                
                self.present(breakTheIcePopupVC, animated: true)
                //self.navigationController?.present(breakTheIcePopupVC, animated: true, completion: nil)
            }
        }
    }
    
    private func waitingForNearByApprove() {
        
        let nearbyWaitingApprovalVC = NearbyWaitingApprovalVC.instantiate(fromAppStoryboard: .NearbyInteraction)
        nearbyWaitingApprovalVC.nearbyUserDetail = self.nearByUserDetail
        
        nearbyWaitingApprovalVC.waitingForSignal { [weak self] isUserBreak in
            
            if isUserBreak {
                if let self = self {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        self.navigationController?.pushViewController(nearbyWaitingApprovalVC, animated: true)
        self.btnBreakTheIce.isUserInteractionEnabled = true
    }
    
    @objc func imgProfileTap(_ sender: UITapGestureRecognizer?) {
        
        switch self.navigationScreen {
                
            case .currentUserProfile, .switchProfile:
                let changeProfilePhotoVC = ChangeProfilePhotoVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                changeProfilePhotoVC.modalTransitionStyle = .crossDissolve
                changeProfilePhotoVC.modalPresentationStyle = .overCurrentContext
                changeProfilePhotoVC.imgProfile = self.imgViewProfile.image
                changeProfilePhotoVC.delegate = self
                self.present(changeProfilePhotoVC, animated: true)
                break
                
            case .discover, .deviceHistory, .map, .QRScan, .dynamicLink, .notification, .businessCardScan:
                let showProfilePhotoVC = ShowProfilePhotoVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                
                if let socialDetail = self.socialDetail {
                    
                    if socialDetail.profile_img != nil && socialDetail.profile_img != "" {
                        showProfilePhotoVC.imgProfile = self.imgViewProfile.image
                        showProfilePhotoVC.view.backgroundColor = UIColor.clear
                        self.present(showProfilePhotoVC, animated: true)
                    }
                } else {
                    
                    if let businessDetail = self.businessDetail {
                        if businessDetail.business_profileURL != nil && businessDetail.business_profileURL != "" {
                            showProfilePhotoVC.imgProfile = self.imgViewProfile.image
                            showProfilePhotoVC.view.backgroundColor = UIColor.clear
                            self.present(showProfilePhotoVC, animated: true)
                        }
                    }
                }
                break
                
            default:
                break
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func loadDataFromAPI(isShowLoader: Bool = false, userMode: String = "") {
        
        if isShowLoader { self.showCustomLoader() }
        
        switch self.navigationScreen {
                
            case .currentUserProfile, .switchProfile: // MARK: currentUserProfile | switchProfile
                
                if userMode == "0" { // Load Social Profile
                    
                    self.callGetInfoAPI(needToShowAlertForFailure: isShowLoader, UserID: UserLocalData.UserID) { isSuccess, response in
                        
                        if isSuccess {
                            
                            if let getInfoAPIResponse = response {
                                self.arrSocialNetwork.removeAll()
                                self.socialDetail = getInfoAPIResponse
                                self.viewAboutMe.isHidden = false
                                loginUser?.social_network = getInfoAPIResponse.social_network
                                self.setUserSocialDetail()
                            }
                            
                        } else {
                            
                            self.viewAboutMe.isHidden = false
                            self.setDefaultUserDetails()
                        }
                    }
                }
                break
                
            case .discover: // MARK: discover
                
                self.callGetInfoAPI(needToShowAlertForFailure: isShowLoader, UserID: self.nearByUserId) { isSuccess, response in
                    
                    if isSuccess {
                        
                        if let getInfoAPIResponse = response {
                            
                            if getInfoAPIResponse.user_mode == "0" || getInfoAPIResponse.subscriptionStatus == "0" {
                                
                                self.arrSocialNetwork.removeAll()
                                self.socialDetail = getInfoAPIResponse
                                self.nearByUserDetail = getInfoAPIResponse
                                self.viewAboutMe.isHidden = false
                                loginUser?.social_network = getInfoAPIResponse.social_network
                                self.setUserSocialDetail()
                            }
                        }
                    }
                }
                break
                
            case .QRScan, .dynamicLink: // MARK: QRScan || dynamicLink
                
                self.viewAboutMe.isHidden = false
                if isShowLoader == true { self.setDefaultUserDetails() }
                
                var slugToSend = ""
                
                if self.slug != "" {
                    let endPoint = self.slug.components(separatedBy: "/")
                    if let lastComponent = endPoint.last {
                        if let index = lastComponent.range(of: "?type=QR") {
                            slugToSend = String(lastComponent[..<index.lowerBound])
                        } else {
                            slugToSend = lastComponent
                        }
                    }
                }
                
                self.callGetInfoAPI(needToShowAlertForFailure: isShowLoader, isFromQRCode: true, slug: slugToSend) { isSuccess, response in
                    
                    if isSuccess {
                        
                        if let getInfoAPIResponse = response {
                            
                            if getInfoAPIResponse.user_mode == "0" || getInfoAPIResponse.subscriptionStatus == "0" {
                                
                                self.arrSocialNetwork.removeAll()
                                self.socialDetail = getInfoAPIResponse
                                self.viewAboutMe.isHidden = false
                                loginUser?.social_network = getInfoAPIResponse.social_network
                                self.setUserSocialDetail()
                                
                                if self.navigationScreen == .QRScan {
                                    
                                    // To add scanQRUser in Interactions List
                                    self.callDeviceScanAPI(scanType: BLEDeviceScanType.QR.rawValue,
                                                           NFCURL: "",
                                                           receiverID: self.socialDetail?.id ?? "",
                                                           lat: LocationManager.shared.locationManager?.location?.coordinate.latitude ?? 0.0,
                                                           lng: LocationManager.shared.locationManager?.location?.coordinate.longitude ?? 0.0)
                                }
                            }
                        }
                    }
                }
                break
                
            case .deviceHistory, .map, .notification, .businessCardScan: // MARK: deviceHistory || map || notification
                
                self.viewAboutMe.isHidden = false
                if isShowLoader == true { self.setDefaultUserDetails() }
                
                if self.isUser_ReferalConnect == true {
                    
                    self.callGetReferenceConnectAPI(userID: self.receiver_id)
                    
                } else {
                    
                    self.callGetInfoAPI(UserID: self.receiver_id) { isSuccess, response in
                        
                        if isSuccess {
                            
                            if let getInfoAPIResponse = response {
                                
                                if getInfoAPIResponse.user_mode == "0" || getInfoAPIResponse.subscriptionStatus == "0" {
                                    
                                    self.arrSocialNetwork.removeAll()
                                    self.socialDetail = getInfoAPIResponse
                                    self.viewAboutMe.isHidden = false
                                    loginUser?.social_network = getInfoAPIResponse.social_network
                                    self.setUserSocialDetail()
                                }
                                
                                if self.navigationScreen == .notification {
                                    
                                    // .notification - if self.isUser_ReferalConnect == false means it's a Blue Social User, Give them BST for Exchange Contact
                                    let randomInt = Int.random(in: 5 ..< 20)
                                    
                                    let exchangeContactVC = ExchangeContactVC.instantiate(fromAppStoryboard: .Discover)
                                    exchangeContactVC.modalTransitionStyle = .crossDissolve
                                    exchangeContactVC.modalPresentationStyle = .overCurrentContext
                                    
                                    exchangeContactVC.navigationScreen = .notification
                                    exchangeContactVC.receiver_id = self.receiver_id
                                    exchangeContactVC.firstName = response?.firstname ?? (response?.name ?? "")
                                    exchangeContactVC.randomBST = "\(randomInt)"
                                    
                                    self.present(exchangeContactVC, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
                break
                
            default:
                break
        }
    }
    
    // getInviteClick
    private func callGetReferenceConnectAPI(userID: String) {
        
        let url = BaseURL + APIName.kGetReferenceConnect
        
        let param: [String: Any] = [APIParamKey.kId: userID]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                if let referenceConnectUserDetail = response?.userDetail {
                    
                    self.setUserSocialInfoInDB(userID: userID, userJSON: referenceConnectUserDetail.toJSONString() ?? "")
                    
                    self.arrSocialNetwork.removeAll()
                    self.socialDetail = referenceConnectUserDetail
                    self.viewAboutMe.isHidden = false
                    self.setUserSocialDetail()
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callClickSocialLinkAPI(sid: String, completion: @escaping (() -> ())) {
        
        if self.navigationScreen != .currentUserProfile && self.navigationScreen != .switchProfile {
            
            let url = BaseURL + APIName.kClickSocialLink
            
            var parameter: [String: Any] = [APIParamKey.kSid: sid]
            
            switch self.navigationScreen {
                    
                case .discover:
                    parameter[APIParamKey.kUserId] = self.nearByUserId
                    
                    if let userMode = self.nearByUserDetail.user_mode {
                        parameter[kUsertype] = userMode
                    } else {
                        parameter[kUsertype] = "0"
                    }
                    break
                    
                case .QRScan, .dynamicLink:
                    parameter[APIParamKey.kUserId] = self.socialDetail?.id
                    
                    if let userMode = self.socialDetail?.user_mode {
                        parameter[kUsertype] = userMode
                    } else {
                        parameter[kUsertype] = "0"
                    }
                    break
                    
                case .deviceHistory, .map, .notification, .businessCardScan:
                    parameter[APIParamKey.kUserId] = self.receiver_id
                    
                    if let userMode = self.socialDetail?.user_mode {
                        parameter[kUsertype] = userMode
                    } else {
                        parameter[kUsertype] = "0"
                    }
                    break
                    
                default:
                    break
            }
            
            //self.showCustomLoader()
            APIManager.postAPIRequest(postURL: url, parameters: parameter) { (isSuccess, msg, response) in
                //self.hideCustomLoader()
                
                if isSuccess {
                    completion()
                } else {
                    //self.showAlertWithOKButton(message: msg)
                }
            }
            
        } else {
            completion()
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        self.cvChip.register(InterestCVCell.nib, forCellWithReuseIdentifier: InterestCVCell.identifier)
        self.cvChip.collectionViewLayout = LeftAlignCollectionLayout()
        self.tblSocialNetwork.register(SocialNetworkTblCell.nib, forCellReuseIdentifier: SocialNetworkTblCell.identifier)
        
        self.lblStatus.isHidden = true
        self.btnShowAll.isHidden = true
        self.viewAboutMe.isHidden = true
        
        self.mapView.layer.cornerRadius = 24.0
        self.mapView.delegate = self
        // self.mapView.isUserInteractionEnabled = false
        
        self.setupScrollView()
        
        self.initialsLabel.frame.size = CGSize(width: 62.0, height: 62.0)
        self.initialsLabel.textColor = .white
        self.initialsLabel.textAlignment = .center
        self.initialsLabel.font = UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        self.initialsLabel.backgroundColor = UIColor.appWhite_FFFFFF_Opacity_16()
        
        switch self.navigationScreen {
                
            case .currentUserProfile:
                if loginUser?.caption != nil && loginUser?.caption != "" {
                    self.btnBluetoothStatus.setTitle(loginUser?.caption, for: .normal)
                } else {
                    self.btnBluetoothStatus.setTitle("Set Caption", for: .normal)
                }
                self.imgViewShare.image = UIImage(named: "ic_share")
                break
                
            case .QRScan, .dynamicLink, .businessCardScan:
                self.btnBluetoothStatus.setTitle("No Caption", for: .normal)
                self.imgViewShare.image = UIImage(named: "ic_share")
                
                self.viewQRCode.isHidden = true
                break
                
            case .deviceHistory, .map, .notification:
                self.btnBluetoothStatus.setTitle("No Caption", for: .normal)
                self.imgViewShare.image = UIImage(named: "ic_Tranparent_notes")
                break
                
            case .discover:
                self.btnBluetoothStatus.setTitle("No Caption", for: .normal)
                self.imgViewShare.image = UIImage(named: "ic_share")
                
                self.viewQRCode.isHidden = true
                
                self.topSVEditProfile.constant = 0.0
                self.heightSVEditProfile.constant = 0.0
                
                self.viewShareProfile.isHidden = true
                
                self.btnMenu.isHidden = false
                self.btnMenu.setImage(UIImage(named: "ic_share_white"), for: .normal)
                
            default:
                break
        }
    }
    
    private func setupCVTVHeight() {
        
        // Reload the data in both views.
        self.cvChip.reloadData()
        self.tblSocialNetwork.reloadData()
        
        // Dispatch to the main queue to ensure the views have updated their content.
        DispatchQueue.main.async {
            // Update the height constraints based on the content size of the table views.
            self.heightCVChip.constant = self.cvChip.contentSize.height
            self.heightTblSocialNetwork.constant = self.tblSocialNetwork.contentSize.height
            
            // Call layoutIfNeeded to update the layout immediately.
            self.view.layoutSubviews()
        }
    }
    
    private func setupScrollView() {
        
        // To Prevent leaving Space from Safe Area
        self.profileScrollView.contentInsetAdjustmentBehavior = .never
        self.profileScrollView.contentInset = UIEdgeInsets.zero
        self.profileScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        self.profileScrollView.contentOffset = CGPointMake(0.0, 0.0)
    }
    
    private func setBackgroundViewForSocialProfile() {
        
        self.imgViewTorus.isHidden = false
        self.imgViewCube.isHidden = false
        self.imgViewCheese.isHidden = false
        self.imgViewConeBlue.isHidden = false
        
        self.imgViewConePurple.isHidden = true
        self.imgViewTorus2.isHidden = true
        self.imgViewCubePurple.isHidden = true
        self.imgViewRock.isHidden = true
        self.btnPro.isHidden = true
        
        let layer = self.viewTop.layer as! CAGradientLayer
        layer.colors = [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()].map{ $0.cgColor }
        
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let bgLayer = self.topBGView.layer as! CAGradientLayer
        bgLayer.colors = [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()].map{ $0.cgColor }
        
        bgLayer.startPoint = CGPoint(x: 0, y: 0.5)
        bgLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
    
    private func setBackgroundViewForBusinessProfile() {
        
        self.imgViewTorus.isHidden = true
        self.imgViewCube.isHidden = true
        self.imgViewCheese.isHidden = true
        self.imgViewConeBlue.isHidden = true
        
        self.imgViewConePurple.isHidden = false
        self.imgViewTorus2.isHidden = false
        self.imgViewCubePurple.isHidden = false
        self.imgViewRock.isHidden = false
        self.btnPro.isHidden = false
        
        let layer = self.viewTop.layer as! CAGradientLayer
        layer.colors = [UIColor.appBlueGradient3_431CB8(), UIColor.appBlueGradient4_182EFF(), UIColor.appBlueGradient5_00C0EE()].map{ $0.cgColor }
        
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let bgLayer = self.topBGView.layer as! CAGradientLayer
        bgLayer.colors = [UIColor.appBlueGradient3_431CB8(), UIColor.appBlueGradient4_182EFF(), UIColor.appBlueGradient5_00C0EE()].map{ $0.cgColor }
        
        bgLayer.startPoint = CGPoint(x: 0, y: 0.5)
        bgLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
    
    private func updateUserProfileUI() {
        
        switch self.navigationScreen {
                
            case .currentUserProfile, .switchProfile:
                
                self.topSVEditProfile.constant = 32.0
                self.heightSVEditProfile.constant = 64.0
                
                if loginUser?.caption != nil && loginUser?.caption != "" {
                    self.btnBluetoothStatus.setTitle(loginUser?.caption, for: .normal)
                } else {
                    self.btnBluetoothStatus.setTitle("Set Caption", for: .normal)
                }
                
                if UserLocalData.userMode == "0" {
                    
                    let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
                    
                    if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                        
                        self.socialDetail = dbUserModel
                        self.viewAboutMe.isHidden = false
                        loginUser?.social_network = dbUserModel.social_network
                        
                        // TODO: For Subscription Status
                        // if self.socialDetail?.subscriptionStatus == "1" {
                        //     self.imgViewSubscriptionStatus.isHidden = false
                        // } else if self.socialDetail?.subscriptionStatus == "0" {
                        //     self.imgViewSubscriptionStatus.isHidden = true
                        // }
                        
                        self.imgViewAddEditProfile.isHidden = false
                        
                        if let profileImage = self.socialDetail?.profile_img {
                            
                            if profileImage == "" {
                                self.imgViewAddEditProfile.image = UIImage(named: "ic_camera_white")
                                
                            } else {
                                self.imgViewAddEditProfile.image = UIImage(named: "ic_edit")
                            }
                        }
                        
                        self.setUserSocialDetail()
                        self.loadDataFromAPI(isShowLoader: false, userMode: "0")
                        
                    } else {
                        
                        self.loadDataFromAPI(isShowLoader: true, userMode: "0")
                    }
                }
                break
                
            case .discover:
                
                //self.btnMenu.isHidden = true
                self.btnMyWallet.isHidden = true
                self.topBtnMyWallet.constant = 0.0
                self.bottomBtnMyWallet.constant = 8.0
                self.heightBtnMyWallet.constant = 0.0
                self.imgViewUserToken.isHidden = true
                self.lblUserToken.isHidden = true
                self.lblToken.isHidden = true
                self.imgViewQRCode.image = UIImage(named: "ic_send_token_new")
                self.lblQRCode.text = "Send Tokens"
                self.viewEditProfile.isHidden = true
                //self.topSVEditProfile.constant = 32.0
                //self.heightSVEditProfile.constant = 64.0
                self.topSVEditProfile.constant = 0.0
                self.heightSVEditProfile.constant = 0.0
                
                self.viewShareProfile.isHidden = true
                
                self.btnMenu.isHidden = false
                self.btnMenu.setImage(UIImage(named: "ic_share_white"), for: .normal)
                
                if self.user_mode == "0" || self.subscriptionStatus == "0" { // Load Social Profile
                    
                    let dbUserData = DBManager.checkUserSocialInfoExist(userID: self.nearByUserId)
                    
                    if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                        
                        self.socialDetail = dbUserModel
                        self.viewAboutMe.isHidden = false
                        self.setUserSocialDetail()
                        self.loadDataFromAPI(isShowLoader: false, userMode: "0")
                        
                    } else {
                        
                        self.loadDataFromAPI(isShowLoader: true, userMode: "0")
                    }
                }
                break
                
            case .deviceHistory, .map, .notification:
                
                if self.isUser_ReferalConnect {
                    
                    self.btnMenu.isHidden = true
                    self.viewQRCode.isHidden = true
                    
                } else {
                    
                    self.btnMenu.isHidden = false
                    self.btnMenu.setImage(UIImage(named: "ic_share_white"), for: .normal)
                    //self.viewQRCode.isHidden = false
                    self.viewQRCode.isHidden = true
                    self.imgViewQRCode.image = UIImage(named: "ic_send_token_new")
                    self.lblQRCode.text = "Send Tokens"
                }
                
                self.lblShare.text = "Notes"
                self.btnMyWallet.isHidden = true
                self.topBtnMyWallet.constant = 0.0
                self.bottomBtnMyWallet.constant = 8.0
                self.heightBtnMyWallet.constant = 0.0
                self.imgViewUserToken.isHidden = true
                self.lblUserToken.isHidden = true
                self.lblToken.isHidden = true
                self.imgViewEditProfile.image = UIImage(named: "ic_add_to_contact")
                self.lblEditProfile.text = "Add to Contact"
                self.btnBreakTheIce.isHidden = true
                self.heightStackViewBreakTheIce.constant = 0.0
                self.topSVEditProfile.constant = 32.0
                self.heightSVEditProfile.constant = 64.0
                
                if self.deviceScanHistory != nil { // .deviceHistory
                    
                    if let dtCreated = self.deviceScanHistory?.dt_created, !dtCreated.isEmpty {
                        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        if let inputDate = self.dateFormatter.date(from: dtCreated) {
                            self.dateFormatter.dateFormat = "MMM dd"
                            let outputDateStr = self.dateFormatter.string(from: inputDate)
                            self.lblResumeTitle.text = "You interacted on \(outputDateStr)"
                        } else {
                            // Handle the case when the date couldn't be parsed
                            print("Invalid Date Format")
                        }
                    } else {
                        self.lblResumeTitle.text = "You interacted on"
                    }
                    
                    self.setupLocationAndMap()
                    
                    let dbUserData = DBManager.checkUserSocialInfoExist(userID: self.deviceScanHistory?.receiver_id ?? "")
                    
                    if dbUserData.userData != nil {
                        
                        if dbUserData.userData?.user_mode == "0" || dbUserData.userData?.subscriptionStatus == "0" {
                            
                            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                                
                                self.socialDetail = dbUserModel
                                self.viewAboutMe.isHidden = false
                                self.setUserSocialDetail()
                                self.loadDataFromAPI(isShowLoader: false, userMode: "0")
                                
                            } else {
                                
                                self.loadDataFromAPI(isShowLoader: true, userMode: "0")
                            }
                            
                        } else {
                            
                            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                                
                                self.socialDetail = dbUserModel
                                self.viewAboutMe.isHidden = false
                                self.setUserSocialDetail()
                                self.loadDataFromAPI(isShowLoader: false, userMode: "0")
                                
                            } else {
                                
                                self.loadDataFromAPI(isShowLoader: true, userMode: "0")
                            }
                        }
                        
                    } else {
                        
                        self.loadDataFromAPI(isShowLoader: true, userMode: "0")
                    }
                    
                } else { // .notification
                    
                    if !self.shouldNotCallAPI {
                        self.loadDataFromAPI(isShowLoader: true)
                    }
                }
                break
                
            case .QRScan, .dynamicLink, .businessCardScan:
                
                self.btnMenu.isHidden = true
                self.btnMyWallet.isHidden = true
                self.topBtnMyWallet.constant = 0.0
                self.bottomBtnMyWallet.constant = 8.0
                self.heightBtnMyWallet.constant = 0.0
                self.imgViewUserToken.isHidden = true
                self.lblUserToken.isHidden = true
                self.lblToken.isHidden = true
                self.imgViewEditProfile.image = UIImage(named: "ic_add_to_contact")
                self.lblEditProfile.text = "Add to Contact"
                self.imgViewQRCode.image = UIImage(named: "ic_send_token_new")
                self.lblQRCode.text = "Send Tokens"
                
                if !self.shouldNotCallAPI {
                    self.loadDataFromAPI(isShowLoader: true)
                }
                break
                
            default:
                break
        }
    }
    
    private func calculateCollectionViewHeight() -> CGFloat {
        let itemCount = showAllItems ? self.arrInterestTopic.count : min(self.arrInterestTopic.count, 9)
        return CGFloat(itemCount) * 48 // Replace itemHeight with the height of each collection view cell
    }
    
    private func getProfileLink() {
        
        if self.socialDetail?.user_mode == "0" || self.socialDetail?.subscriptionStatus == "0" {
            
            let link = URL(string: self.socialDetail?.unique_url ?? "")
            self.shareUserProfile = link
            
        } else {
            
            let link = URL(string: self.businessDetail?.unique_url ?? "")
            self.shareUserProfile = link
        }
    }
    
    func getCurrentUserUpdate(myCompletion: @escaping GetCurrentUserUpdate) {
        
        self.getCurrentUserUpdate = myCompletion
    }
    
    private func openMapForPlace(lat: String, long: String, placeName: String) {
        
        let lat1: NSString = lat as NSString
        let lng1: NSString = long as NSString
        
        let latitude: CLLocationDegrees = lat1.doubleValue
        let longitude: CLLocationDegrees = lng1.doubleValue
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: options)
    }
    
    func drawImageWithProfilePic(pp: UIImage, image: UIImage) -> UIImage {
        
        let imgView = UIImageView(image: image)
        let picImgView = UIImageView(image: pp)
        picImgView.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        
        imgView.addSubview(picImgView)
        picImgView.center.x = imgView.center.x
        picImgView.center.y = imgView.center.y - 4
        picImgView.layer.cornerRadius = picImgView.frame.width/2
        picImgView.clipsToBounds = true
        imgView.setNeedsLayout()
        picImgView.setNeedsLayout()
        
        let newImage = self.imageWithView(view: imgView)
        
        return newImage
    }
    
    func imageWithView(view: UIView) -> UIImage {
        
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
        }
        return image ?? UIImage()
    }
}

extension ProfileVC: ProfileDelegate {
    
    func callViewWillAppear() {
        self.viewWillAppear(false)
    }
}

extension ProfileVC: CaptionDelegate {
    
    func setCaption(caption: String) {
        self.btnBluetoothStatus.setTitle(caption, for: .normal)
    }
}

extension ProfileVC: GMSMapViewDelegate {
    
    private func setupLocationAndMap() {
        
        LocationManager.shared.setupLocationManager()
        
        let camera = GMSCameraPosition.camera(withLatitude: self.deviceScanHistory?.userLatitude ?? 0.0, longitude: self.deviceScanHistory?.userLongitude ?? 0.0, zoom: 12.0)
        //self.mapView.camera = camera
        self.mapView.animate(to: camera)
        
        self.addMapPin(position: camera.target)
    }
    
    private func addMapPin(position: CLLocationCoordinate2D) {
        
        self.marker.position = position
        
        if let url = URL(string: self.deviceScanHistory?.profile_url ?? "") {
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    // Ensure UI updates are on the main thread
                    DispatchQueue.main.async {
                        self.imgPP = UIImage(data: data)
                        // Set marker icon after image is loaded
                        self.marker.icon = self.drawImageWithProfilePic(pp: self.imgPP ?? UIImage(), image: UIImage(named: "ic_white_Shadow_pin") ?? UIImage())
                        self.marker.appearAnimation = GMSMarkerAnimation.pop
                        self.marker.map = self.mapView
                    }
                } else if let error = error {
                    print("Error loading image: \(error)")
                }
            }.resume()
            
        } else {
            // Set default image if URL is invalid or empty
            self.imgPP = UIImage.imageWithInitial(initial: "\(self.deviceScanHistory?.firstname?.capitalized.first ?? "A")\(self.deviceScanHistory?.lastname?.capitalized.first ?? "B")", imageSize: CGSize(width: 62.0, height: 62.0), gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            
            // Set marker icon with default image
            self.marker.icon = self.drawImageWithProfilePic(pp: self.imgPP ?? UIImage(), image: UIImage(named: "ic_white_Shadow_pin") ?? UIImage())
            self.marker.appearAnimation = GMSMarkerAnimation.pop
            self.marker.map = self.mapView
        }
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension ProfileVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSocialNetwork.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tblSocialNetwork.dequeueReusableCell(withIdentifier: SocialNetworkTblCell.identifier) as? SocialNetworkTblCell {
            
            cell.configureCell(objSocialNetworkList: self.arrSocialNetwork[indexPath.row], isFromProfileVC: true)
            
            for blurview in cell.viewBlur.subviews {
                if let blurV = blurview as? DynamicBlurView {
                    blurV.removeFromSuperview()
                }
            }
            cell.isUserInteractionEnabled = true
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView Delegate -
// ----------------------------------------------------------
extension ProfileVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var clickURLs = (self.arrSocialNetwork[indexPath.row].social_help_input_type ?? "") + (self.arrSocialNetwork[indexPath.row].value ?? "").trime()
        print("clickURLs: \(clickURLs)")
        
        let type = (self.arrSocialNetwork[indexPath.row].social_name ?? "").lowercased().trime().replacingOccurrences(of: " ", with: "")
        
        self.callClickSocialLinkAPI(sid: self.arrSocialNetwork[indexPath.row].sid ?? "") {}
            
        switch type {
                
            case SocialNetworkCellType.email.type():
                
                // TODO: email
                let mailComposeViewController = self.configuredMailComposeViewController()
                mailComposeViewController.setPreferredSendingEmailAddress((self.arrSocialNetwork[indexPath.row].value ?? "").trime())
                mailComposeViewController.setToRecipients([(self.arrSocialNetwork[indexPath.row].value ?? "").trime()])
                
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showAlertWithOKButton(message: "Email is not configured")
                }
                break
                
            case SocialNetworkCellType.Address.type():
                
                // TODO: Address
                //                    self.getLatlongFrom(address: self.arrSocialNetwork[indexPath.row].value ?? "") { (location, error) in
                //
                //                        if error == nil {
                //                            self.openMapForPlace(lat: "\(location.coordinate.latitude)", long: "\(location.coordinate.longitude)", placeName: self.arrSocialNetwork[indexPath.row].value ?? "")
                //                        }
                //                    }
                
                self.openAppleMap(with: self.arrSocialNetwork[indexPath.row].value ?? "")
                break
                
            case SocialNetworkCellType.Paypal.type():
                
                // TODO: Paypal
                let appScheme = "paypal://)"
                let appUrl = URL(string: appScheme)
                
                if UIApplication.shared.canOpenURL(appUrl! as URL) {
                    UIApplication.shared.open(appUrl!)
                    
                } else  {
                    if let url = URL(string: clickURLs) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    } else {
                        self.showAlertWithOKButton(message: "Invalid URL")
                    }
                }
                break
                
            case SocialNetworkCellType.Phone.type():
                
                // TODO: Phone
                let contactNumberWithCountryCodeName = (self.arrSocialNetwork[indexPath.row].value ?? "").components(separatedBy: "_")
                let contactNumber = contactNumberWithCountryCodeName.count >= 3 ? contactNumberWithCountryCodeName[2] : contactNumberWithCountryCodeName[0]
                print("contactNumber: \(contactNumber)")
                let appScheme = "tel:\(contactNumber)"
                if let url = URL(string: appScheme) {
                    let canOpen = UIApplication.shared.canOpenURL(url)
                    print("Can open URL: \(canOpen)")
                    if canOpen {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        self.showAlertWithOKButton(message: "Invalid URL")
                    }
                } else {
                    self.showAlertWithOKButton(message: "Invalid URL")
                }
                break
                
            case SocialNetworkCellType.Website.type(), SocialNetworkCellType.Resume.type(), SocialNetworkCellType.Calendly.type(), SocialNetworkCellType.CustomLink.type(), SocialNetworkCellType.GoogleMyBusiness.type(), SocialNetworkCellType.Linkedin.type(), SocialNetworkCellType.Slack.type():
                
                // TODO: Website, Resume, Calendly, CustomLink, GoogleMyBusiness, Linkedin, Slack
                if var linkValue = self.arrSocialNetwork[indexPath.row].value {
                    
                    if !linkValue.hasPrefix("http") {
                        
                        linkValue = "https://" + (self.arrSocialNetwork[indexPath.row].value ?? "")
                    }
                    
                    if let url = URL(string: linkValue) {
                        
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }  else {
                            self.showAlertWithOKButton(message: "Invalid URL")
                        }
                        
                    } else {
                        self.showAlertWithOKButton(message: "Invalid URL")
                    }
                }
                break
                
            case SocialNetworkCellType.Whatsapp.type():
                
                // TODO: Whatsapp
                let fullNameArr = self.arrSocialNetwork[indexPath.row].value?.components(separatedBy: "_")
                print("Final URL for Whatsapp:\(String(describing: fullNameArr))")
                
                let urlWhats = "https://wa.me/\(String(describing: fullNameArr?[2] ?? ""))"
                
                print("Final URL for Whatsapp:\(urlWhats)")
                
                if let url = URL(string: urlWhats) {
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }  else {
                        self.showAlertWithOKButton(message: "Invalid URL")
                    }
                } else {
                    self.showAlertWithOKButton(message: "Invalid URL")
                }
                break
                
            case SocialNetworkCellType.Zelle.type(), SocialNetworkCellType.Wechat.type(), SocialNetworkCellType.PokemonGo.type(), SocialNetworkCellType.EthereumAddress.type(), SocialNetworkCellType.BitcoinWalletAddress.type(), SocialNetworkCellType.PlayStation.type(), SocialNetworkCellType.Xbox.type():
                
                // TODO: Zelle, Wechat, PokemonGo, EthereumAddress, BitcoinWalletAddress, PlayStation, Xbox
                let showSocialNetworkVC = ShowSocialNetworkVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                
                ImageCache().getImage(from: URL(string: (self.arrSocialNetwork[indexPath.row].social_icon ?? ""))!) { image, error in
                    
                    if image != nil {
                        showSocialNetworkVC.imgSocialNetwork = image
                    }
                }
                showSocialNetworkVC.socialNetworkName = self.arrSocialNetwork[indexPath.row].social_title?.capitalized
                
                if self.arrSocialNetwork[indexPath.row].social_name == "zelle" {
                    showSocialNetworkVC.socialNetworkTitle = "Zelle ID:"
                } else if self.arrSocialNetwork[indexPath.row].social_name?.lowercased() == "wechat" {
                    showSocialNetworkVC.socialNetworkTitle = "Wechat ID:"
                } else {
                    showSocialNetworkVC.socialNetworkTitle = self.arrSocialNetwork[indexPath.row].social_help_input_type
                }
                
                showSocialNetworkVC.value = self.arrSocialNetwork[indexPath.row].value
                showSocialNetworkVC.view.backgroundColor = UIColor.clear
                self.present(showSocialNetworkVC, animated: true)
                break
                
            default:
                
                // TODO: Instagram, Snapchat, Twitter, TikTok, Facebook, YouTube, Twitch, Pinterest, Apple Music, Spotify, SoundCloud, Venmo, Paypal, Cash app, Vimeo, Patreon, Apple Podcasts, Amazon, Etsy, Yelp, Discord, Telegram
                
                let link = self.arrSocialNetwork[indexPath.row]
                if let value = link.value {
                    if value.contains("http") || value.contains("https") {
                        clickURLs = value
                    }
                }
                
                if let url = URL(string: clickURLs) {
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }  else {
                        self.showAlertWithOKButton(message: "Invalid URL")
                    }
                } else {
                    self.showAlertWithOKButton(message: "Invalid URL")
                }
                break
        }
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension ProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.showAllItems {
            return self.arrInterestTopic.count
            
        } else {
            return min(self.arrInterestTopic.count, 9)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let interestCell = self.cvChip.dequeueReusableCell(withReuseIdentifier: InterestCVCell.identifier, for: indexPath) as? InterestCVCell {
            
            interestCell.configureCell(model: self.arrInterestTopic[indexPath.row])
            return interestCell
        }
        
        return UICollectionViewCell()
    }
}

// -------------------------------------------------------------
//                MARK: - UICollectionViewDelegateFlowLayout -
// -------------------------------------------------------------
extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label: UILabel = UILabel()
        label.text = self.arrInterestTopic[indexPath.item].name
        label.sizeToFit()
        
        self.labelWidth = label.frame.size.width
        
        let cellWidth = self.labelWidth + self.spacing + (2 * self.padding) // Here 24 is imageWidth
        let cellHeight: CGFloat = 40 // Set the desired height of the cell
        
        let cellMaxWidth = UIScreen.main.bounds.width - 32 // 16 leading + 16 trailing
        
        if cellWidth < cellMaxWidth {
            return CGSize(width: cellWidth, height: cellHeight)
        } else {
            return CGSize(width: cellMaxWidth, height: cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// ----------------------------------------------------------
//                       MARK: - SetDefaultUserDetails -
// ----------------------------------------------------------
extension ProfileVC {
    
    private func setDefaultUserDetails() {
        
        self.viewBlur.isHidden = true
        self.viewBlur1.isHidden = true
        self.imgViewLocked.isHidden = true
        
        self.setBackgroundViewForSocialProfile()
        
        self.lblUserName.text = "--"
        
        self.imgViewProfile.image = UIImage.imageWithInitial(initial: "AB", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appWhite_FFFFFF_Opacity_16(), UIColor.appWhite_FFFFFF_Opacity_16()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
        
        self.lblUserProfileViewCount.text = "0"
        self.lblLinkClicksCount.text = "0"
        self.lblUserInteractionCount.text = "0"
        
        self.lblBio.text = "No information has been added"
        self.lblBio.textColor = UIColor.appGray_98A2B1()
        
        self.lblStatus.isHidden = false
        self.lblStatus.text = "No interest has been added"
        self.cvChip.isHidden = true
        self.btnShowAll.isHidden = true
        
        self.viewNoNetwork.isHidden = false
        self.tblSocialNetwork.isHidden = true
        self.heightTblSocialNetwork.constant = 0.0
        
        self.stackViewMap.isHidden = true
        self.btnBreakTheIce.isHidden = true
        self.heightStackViewBreakTheIce.constant = 0.0
        self.lblResumeTitle.isHidden = true
        
        DispatchQueue.main.async {
            // Force layout update
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - SetUserSocialDetail -
// ----------------------------------------------------------
extension ProfileVC {
    
    private func setUserSocialDetail() {
        
        if let socialDetail = self.socialDetail {
            
            self.setBackgroundViewForSocialProfile()
            
            // MARK: - COMMON -
            // MARK: ------------------------------Profile Image---------------------------------
            
            if let url = URL(string: socialDetail.profile_img ?? "") {
                
                self.imgViewProfile.af_setImage(withURL: url)
                
            } else {
                
                self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\(socialDetail.firstname?.capitalized.first ?? "A")\(socialDetail.lastname?.capitalized.first ?? "B")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appWhite_FFFFFF_Opacity_16(), UIColor.appWhite_FFFFFF_Opacity_16()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            }
            
            // MARK: ------------------------------User Name-------------------------------------
            
            let userName = (socialDetail.firstname?.capitalizingFirstLetter() ?? "A") + " " + (socialDetail.lastname?.capitalizingFirstLetter() ?? "B")
            self.lblUserName.text = userName.isEmpty ? socialDetail.name : userName
            
            // MARK: ------------------------------Company | University--------------------------
            
            if socialDetail.profession_type == "1" { // Public
                
                if socialDetail.company_name != nil && socialDetail.company_name != "" {
                    self.lblCompanyOrUniversityName.isHidden = false
                    self.lblCompanyOrUniversityName.text = socialDetail.company_name
                    
                } else {
                    self.lblCompanyOrUniversityName.isHidden = true
                    self.imgViewBlurCompanyOrUniversityName.isHidden = true
                }
                
            } else {
                
                self.lblCompanyOrUniversityName.isHidden = true
                self.imgViewBlurCompanyOrUniversityName.isHidden = true
            }
            
            if socialDetail.caption != nil {
                self.btnBluetoothStatus.setTitle(socialDetail.caption, for: .normal)
            } else {
                self.btnBluetoothStatus.setTitle("No Caption", for: .normal)
            }
            
            self.getProfileLink()
            
            // MARK: ------------------------------View Counts | Interactions | Tokens---------
            
            self.lblUserProfileViewCount.text = socialDetail.view_counts ?? "0"
            self.lblLinkClicksCount.text = socialDetail.linksTapped ?? "0"
            self.lblUserInteractionCount.text = socialDetail.interactions ?? "0"
            self.lblUserToken.text = "\(socialDetail.totalBST ?? 0)"
            
            // MARK: ------------------------------Bio-------------------------------------------
            
            if self.navigationScreen == .currentUserProfile || self.navigationScreen == .switchProfile {
                self.lblBio.text = socialDetail.bio != "" && socialDetail.bio != nil ? socialDetail.bio : "You have not added this information yet"
            } else {
                self.lblBio.text = socialDetail.bio != "" && socialDetail.bio != nil ? socialDetail.bio : "No information has been added"
            }
            
            if socialDetail.bio == "" || socialDetail.bio == nil { self.lblBio.textColor = UIColor.appGray_98A2B1() }
            self.viewBlur.isHidden = true
            
            // MARK: ------------------------------Interest Topics-------------------------------
            
            self.arrInterestTopic = socialDetail.userInterest ?? [User_Interest]()
            
            if self.arrInterestTopic.count == 0 {
                
                self.lblStatus.text = (self.navigationScreen == .currentUserProfile || self.navigationScreen == .switchProfile) ? "You have not added this information yet" : "No interest has been added"
                self.lblStatus.isHidden = false
                self.cvChip.isHidden = true
                self.btnShowAll.isHidden = true
                
            } else if self.arrInterestTopic.count > 9 {
                self.lblStatus.isHidden = true
                self.cvChip.isHidden = false
                self.btnShowAll.isHidden = false
                
            } else {
                self.lblStatus.isHidden = true
                self.cvChip.isHidden = false
                self.btnShowAll.isHidden = true
            }
            self.viewBlur1.isHidden = true
            
            if self.navigationScreen != .deviceHistory || self.navigationScreen != .map {
                
                if let arrCustomInterestFromUD = UserLocalData.arrCustomInterest {
                    
                    self.arrCustomInterestTopic = arrCustomInterestFromUD
                }
                
                // Retrieve the selected elements from arrCustomInterestTopic.
                if let selectedElements = self.arrCustomInterestTopic?.filter({ $0.selected == true }) {
                    
                    // Save the modified array back to UserDefaults
                    UserLocalData.arrCustomInterest = selectedElements
                    
                    self.arrInterestTopic += selectedElements
                }
            }
            
            // MARK: ------------------------------Refresh Array For Social Network-------------------------
            
            self.arrSocialNetwork.removeAll()
            
            if let social_network = socialDetail.social_network {
                for index in 0 ..< social_network.count {
                    if let socialNetworkList = social_network[index].social_network_list {
                        for i in 0 ..< socialNetworkList.count {
                            if let value = socialNetworkList[i].value, !value.isEmpty {
                                self.arrSocialNetwork.append(socialNetworkList[i])
                                
                                //print("arrSocialNetwork COUNT :: \(self.arrSocialNetwork.count)")
                                //print(":: arrSocialNetwork Before SORTING ::")
                                
                                // for (index, element) in self.arrSocialNetwork.enumerated() {
                                // print("Index: \(index), Element: \(element.social_name ?? ""), social_app_order: \(element.social_app_order ?? "")")
                                // }
                            }
                        }
                    }
                }
            }
            
            // Sort the array in ascending order based on social_app_order
            self.arrSocialNetwork.sort { (social1, social2) -> Bool in
                // Convert social_app_order strings to integers
                guard let order1 = Int(social1.social_app_order ?? ""),
                      let order2 = Int(social2.social_app_order ?? "") else {
                    return false // If conversion fails, maintain current order
                }
                
                // Compare integers
                return order1 < order2
            }
            
            //print(":: arrSocialNetwork After SORTING ::")
            
            //            for (index, element) in self.arrSocialNetwork.enumerated() {
            //                print("Index: \(index), Element: \(element.social_name ?? ""), social_app_order: \(element.social_app_order ?? "")")
            //            }
            
            self.tblSocialNetwork.reloadData()
            
            // MARK: Social Network
            
            if self.navigationScreen == .currentUserProfile || self.navigationScreen == .deviceHistory || self.navigationScreen == .map || self.navigationScreen == .notification || self.navigationScreen == .switchProfile { // MARK: currentUserProfile || deviceHistory || map || notification || switchProfile
                
                // ------------------------------Social Network-------------------------
                
                if self.arrSocialNetwork.count == 0 {
                    self.viewNoNetwork.isHidden = false
                    self.tblSocialNetwork.isHidden = true
                    self.heightTblSocialNetwork.constant = 0.0
                    
                } else {
                    self.viewNoNetwork.isHidden = true
                    self.tblSocialNetwork.isHidden = false
                    self.heightTblSocialNetwork.constant = CGFloat((self.arrSocialNetwork.count * 84))
                }
                self.imgViewLocked.isHidden = true
                
            } else if self.navigationScreen == .discover || self.navigationScreen == .QRScan || self.navigationScreen == .dynamicLink || self.navigationScreen == .businessCardScan { // MARK: discover || QRScan || dynamicLink
                
                if socialDetail.private_mode == "0" {
                    
                    // ------------------------------Social Network-------------------------
                    
                    if self.arrSocialNetwork.count == 0 {
                        self.viewNoNetwork.isHidden = false
                        self.tblSocialNetwork.isHidden = true
                        self.heightTblSocialNetwork.constant = 0.0
                        
                    } else {
                        self.viewNoNetwork.isHidden = true
                        self.tblSocialNetwork.isHidden = false
                        
                        self.heightTblSocialNetwork.constant = CGFloat((self.arrSocialNetwork.count * 84))
                        self.view.layoutSubviews()
                    }
                    self.imgViewLocked.isHidden = true
                    
                } else if socialDetail.private_mode == "1" {
                    
                    self.viewNoNetwork.isHidden = true
                    self.tblSocialNetwork.isHidden = true
                    self.heightTblSocialNetwork.constant = 0.0
                    self.imgViewLocked.isHidden = false
                }
            }
            
            // TODO: For Private Bio | Interest Topics | Social Network
            /*
             // MARK: Bio | Interest Topics | Social Network
             
             if self.navigationScreen == .currentUserProfile || self.navigationScreen == .deviceHistory { // MARK: currentUserProfile || deviceHistory
             
             // ------------------------------Bio-------------------------
             
             self.lblBio.isHidden = false
             self.viewBlur.isHidden = true
             
             // ------------------------------Interest Topics-------------------------
             
             if self.arrInterestTopic.count == 0 {
             self.lblStatus.isHidden = false
             self.cvChip.isHidden = true
             self.btnShowAll.isHidden = true
             
             } else if self.arrInterestTopic.count > 9 {
             self.lblStatus.isHidden = true
             self.cvChip.isHidden = false
             self.btnShowAll.isHidden = false
             
             } else {
             self.lblStatus.isHidden = true
             self.cvChip.isHidden = false
             self.btnShowAll.isHidden = true
             }
             self.viewBlur1.isHidden = true
             
             // ------------------------------Social Network-------------------------
             
             if self.arrSocialNetwork.count == 0 {
             self.viewNoNetwork.isHidden = false
             self.tblSocialNetwork.isHidden = true
             self.heightTblSocialNetwork.constant = 0.0
             
             } else {
             self.viewNoNetwork.isHidden = true
             self.tblSocialNetwork.isHidden = false
             self.heightTblSocialNetwork.constant = self.tblSocialNetwork.contentSize.height
             }
             self.imgViewLocked.isHidden = true
             
             } else if self.navigationScreen == .discover || self.navigationScreen == .QRScan { // MARK: discover || QRScan || dynamicLink
             
             if socialDetail.private_mode == "0" {
             
             // ------------------------------Bio-------------------------
             
             self.lblBio.isHidden = false
             self.viewBlur.isHidden = true
             
             // ------------------------------Interest Topics-------------------------
             
             if self.arrInterestTopic.count == 0 {
             self.lblStatus.isHidden = false
             self.cvChip.isHidden = true
             self.btnShowAll.isHidden = true
             
             } else if self.arrInterestTopic.count > 9 {
             self.lblStatus.isHidden = true
             self.cvChip.isHidden = false
             self.btnShowAll.isHidden = false
             
             } else {
             self.lblStatus.isHidden = true
             self.cvChip.isHidden = false
             self.btnShowAll.isHidden = true
             }
             self.viewBlur1.isHidden = true
             
             // ------------------------------Social Network-------------------------
             
             if self.arrSocialNetwork.count == 0 {
             self.viewNoNetwork.isHidden = false
             self.tblSocialNetwork.isHidden = true
             self.heightTblSocialNetwork.constant = 0.0
             
             } else {
             self.viewNoNetwork.isHidden = true
             self.tblSocialNetwork.isHidden = false
             self.heightTblSocialNetwork.constant = self.tblSocialNetwork.contentSize.height
             }
             self.imgViewLocked.isHidden = true
             
             } else if socialDetail.private_mode == "1" {
             
             if let privateModeList = socialDetail.private_mode_list {
             
             for item in privateModeList {
             
             if item.selected == "1" {
             
             if item.name == "About Me" {
             
             self.lblBio.isHidden = true
             self.viewBlur.isHidden = false
             
             } else if item.name == "Interests" {
             
             self.lblStatus.isHidden = true
             self.cvChip.isHidden = true
             self.btnShowAll.isHidden = true
             self.viewBlur1.isHidden = false
             
             } else if item.name == "Social Networks" {
             
             self.viewNoNetwork.isHidden = true
             self.tblSocialNetwork.isHidden = true
             self.heightTblSocialNetwork.constant = 0.0
             self.imgViewLocked.isHidden = false
             }
             
             } else if item.selected == "0" {
             
             if item.name == "About Me" {
             
             // ------------------------------Bio-------------------------
             
             self.lblBio.isHidden = false
             self.viewBlur.isHidden = true
             
             } else if item.name == "Interests" {
             
             // ------------------------------Interest Topics-------------------------
             
             if self.arrInterestTopic.count == 0 {
             self.lblStatus.isHidden = false
             self.cvChip.isHidden = true
             self.btnShowAll.isHidden = true
             
             } else if self.arrInterestTopic.count > 9 {
             self.lblStatus.isHidden = true
             self.cvChip.isHidden = false
             self.btnShowAll.isHidden = false
             
             } else {
             self.lblStatus.isHidden = true
             self.cvChip.isHidden = false
             self.btnShowAll.isHidden = true
             }
             self.viewBlur1.isHidden = true
             
             } else if item.name == "Social Networks" {
             
             // ------------------------------Social Network-------------------------
             
             if self.arrSocialNetwork.count == 0 {
             self.viewNoNetwork.isHidden = false
             self.tblSocialNetwork.isHidden = true
             self.heightTblSocialNetwork.constant = 0.0
             
             } else {
             self.viewNoNetwork.isHidden = true
             self.tblSocialNetwork.isHidden = false
             self.heightTblSocialNetwork.constant = self.tblSocialNetwork.contentSize.height
             }
             self.imgViewLocked.isHidden = true
             }
             }
             }
             }
             }
             }
             */
            
            // MARK: Map | Resume | Break The Ice
            
            if self.navigationScreen == .currentUserProfile || self.navigationScreen == .switchProfile || self.navigationScreen == .businessCardScan { // MARK: currentUserProfile || switchProfile
                
                // ------------------------------Resume-------------------------
                
                self.lblResumeTitle.isHidden = true
                self.stackViewMap.isHidden = true
                self.btnBreakTheIce.isHidden = true
                self.heightStackViewBreakTheIce.constant = 0.0
                
            } else if self.navigationScreen == .discover { // MARK: discover
                
                // ------------------------------Break The Ice-------------------------
                
                self.stackViewMap.isHidden = true
                self.btnBreakTheIce.isHidden = false
                self.heightStackViewBreakTheIce.constant = 48.0
                self.lblResumeTitle.isHidden = true
                
            } else if self.navigationScreen == .QRScan || self.navigationScreen == .dynamicLink { // MARK: QRScan || dynamicLink
                
                // ------------------------------Break The Ice-------------------------
                
                self.stackViewMap.isHidden = true
                self.btnBreakTheIce.isHidden = false
                self.heightStackViewBreakTheIce.constant = 48.0
                self.lblResumeTitle.isHidden = true
                
                self.btnBreakTheIce.setTitle("Exchange Contact", for: .normal)
                
            } else if self.navigationScreen == .deviceHistory || self.navigationScreen == .map { // MARK: deviceHistory || map
                
                // ------------------------------Map-------------------------
                
                self.stackViewResume.isHidden = true
                self.lblNoDocument.isHidden = true
                
                if let userLatitude = self.deviceScanHistory?.userLatitude, let userLongitude = self.deviceScanHistory?.userLongitude, userLatitude != 0.0, userLongitude != 0.0 {
                    self.stackViewMap.isHidden = false
                    self.mapView.isHidden = false
                    self.lblResumeTitle.isHidden = false
                    
                } else {
                    self.stackViewMap.isHidden = true
                    self.mapView.isHidden = true
                    self.lblResumeTitle.isHidden = true
                }
                
            }
        }
        
        DispatchQueue.main.async {
            // Force layout update
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
        }
    }
}

extension ProfileVC: MFMailComposeViewControllerDelegate {
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([loginUser?.s_email ?? ""])
        mailComposerVC.setPreferredSendingEmailAddress(loginUser?.email ?? "")
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail compose view controller
        controller.dismiss(animated: true, completion: nil)
        
        // Handle the result
        switch result {
            case .cancelled:
                // Handle cancellation
                // You can perform any action you want when the user cancels composing the email
                print("User cancelled composing the email")
            case .saved:
                // Handle saving
                print("Email saved as a draft")
            case .sent:
                // Handle sending
                print("Email sent successfully")
            case .failed:
                // Handle failure
                print("Email sending failed")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            @unknown default:
                fatalError("Unknown case")
        }
    }
}

extension ProfileVC: CNContactViewControllerDelegate {
    
    private func addContectData() {
        
        self.shouldNotCallAPI = true
        
        var arrEmail   = [CNLabeledValue<NSString>]()
        var arrSocial  = [CNLabeledValue<CNSocialProfile>]()
        var arrContact = [CNLabeledValue<CNPhoneNumber>]()
        let newContact = CNMutableContact()
        
        if let socialDetail = self.socialDetail {
            
            if socialDetail.company_name != "" && socialDetail.company_name != nil {
                
                if !arrSocial.map({$0.value.username}).contains(socialDetail.company_name ?? "") {
                    let companyProfile = CNLabeledValue(label: "Company Name", value: CNSocialProfile(urlString: nil, username: "\(socialDetail.company_name ?? "")", userIdentifier: nil, service: "Company Name"))
                    arrSocial.append(companyProfile)
                }
            }
            
            if let title = socialDetail.title {
                
                if title != "" {
                    
                    if !arrSocial.map({$0.value.username}).contains(title) {
                        let titleProfile = CNLabeledValue(label: "Title", value: CNSocialProfile(urlString: nil, username: "\(title)", userIdentifier: nil, service: "Title"))
                        arrSocial.append(titleProfile)
                    }
                }
            }
            
            if let firstName = socialDetail.firstname {
                
                if firstName != "" {
                    
                    newContact.givenName = firstName
                }
            }
            
            if let lastName = socialDetail.lastname {
                
                if lastName != "" {
                    
                    newContact.familyName = lastName
                }
            }
            
            for index in 0 ... (socialDetail.social_network?.count ?? 0) - 1 {
                
                var isAddSocial: Bool = true
                
                if socialDetail.social_network![index].social_category_title!.lowercased().replacingOccurrences(of: " ", with: "").contains(SocialNetworkCategoryType.AnalysisAdvertising.type().lowercased()) || socialDetail.social_network![index].social_category_title!.lowercased().replacingOccurrences(of: " ", with: "").contains(SocialNetworkCategoryType.CustomFiles.type().lowercased()) || socialDetail.social_network![index].social_category_title!.lowercased().replacingOccurrences(of: " ", with: "").contains(SocialNetworkCategoryType.CustomLinks.type().lowercased())  || socialDetail.social_network![index].social_category_title!.lowercased().replacingOccurrences(of: " ", with: "").contains(SocialNetworkCategoryType.PersonalContacts.type().lowercased()) {
                    
                    isAddSocial = false
                }
                
                for i in 0 ... socialDetail.social_network![index].social_network_list!.count - 1 {
                    
                    if socialDetail.social_network![index].social_network_list![i].value != nil && socialDetail.social_network![index].social_network_list![i].value != "" {
                        
                        let urlList = socialDetail.social_network![index].social_network_list![i] // Profile
                        
                        if urlList.value != nil && urlList.value!.count > 0 {
                            
                            if urlList.social_name!.lowercased().contains("email") {
                                
                                if !arrEmail.map({$0.value}).contains(urlList.value! as NSString){
                                    let Email = CNLabeledValue(label: "Email", value: urlList.value! as NSString)
                                    arrEmail.append(Email)
                                }
                                
                            } else if urlList.social_name!.lowercased().replacingOccurrences(of: " ", with: "") == SocialNetworkCellType.Phone.type() || urlList.social_name!.lowercased().replacingOccurrences(of: " ", with: "") == SocialNetworkCellType.Whatsapp.type() {
                                
                                var code = ""
                                var contactNumber = ""
                                let strmobile = urlList.value
                                
                                if (strmobile != nil) {
                                    let fullNameArr = self.socialDetail?.mobile?.components(separatedBy: "_") ?? [""]
                                    code = fullNameArr.count >= 2 ? fullNameArr[1] : code
                                    contactNumber = fullNameArr.count >= 3 ? fullNameArr[2] : contactNumber
                                    code = code.contains("+") ? code : "+" + code
                                }
                                
                                arrContact.append((CNLabeledValue(label: urlList.social_name?.capitalizingFirstLetter(), value: CNPhoneNumber(stringValue: (code + contactNumber)))))
                                
                            } else if urlList.social_name!.lowercased().contains("website") {
                                
                                arrSocial.append((CNLabeledValue(label: urlList.social_name?.capitalizingFirstLetter(), value: CNSocialProfile(urlString: nil, username: urlList.value!, userIdentifier: nil, service: urlList.social_title?.capitalizingFirstLetter()))))
                                
                            } else if urlList.social_name!.lowercased().contains("resume") {
                                
                                arrSocial.append((CNLabeledValue(label: urlList.social_name?.capitalizingFirstLetter(), value: CNSocialProfile(urlString: nil, username: urlList.value!, userIdentifier: nil, service: urlList.social_name?.capitalizingFirstLetter()))))
                                
                            } else if urlList.social_name!.lowercased().contains("calendly") {
                                
                                arrSocial.append((CNLabeledValue(label:urlList.social_name?.capitalizingFirstLetter(), value: CNSocialProfile(urlString: nil, username: urlList.value!, userIdentifier: nil, service: urlList.social_title?.capitalizingFirstLetter()))))
                                
                            } else if isAddSocial {
                                
                                var userName = urlList.social_help_input_type! +  urlList.value!
                                
                                if (urlList.value?.range(of: "http", options: .caseInsensitive) != nil) || (urlList.value?.range(of: "https", options: .caseInsensitive) != nil) {
                                    userName = urlList.value!
                                }
                                
                                if !arrSocial.map({$0.value.username}).contains(userName) {
                                    
                                    if urlList.social_name?.lowercased() == "twitter" {
                                        arrSocial.append((CNLabeledValue(label: "Twitter", value: CNSocialProfile(urlString: nil, username: userName, userIdentifier: nil, service: "Twitter"))))
                                    } else {
                                        
                                        arrSocial.append((CNLabeledValue(label: urlList.social_name?.capitalizingFirstLetter(), value: CNSocialProfile(urlString: nil, username: userName, userIdentifier: nil, service: urlList.social_title?.capitalizingFirstLetter()))))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                
                guard let profile = socialDetail.profile_img else { return }
                
                if profile != "" {
                    let url = URL(string: profile)
                    guard let imgData = try? Data(contentsOf: url!) else { return }
                    newContact.imageData = imgData
                }
            }
            
            newContact.emailAddresses = arrEmail
            newContact.socialProfiles = arrSocial
            newContact.phoneNumbers = arrContact
            
            let contactVC = CNContactViewController(forUnknownContact: newContact)
            contactVC.contactStore = CNContactStore()
            contactVC.delegate = self
            contactVC.allowsActions = false
            
            self.title = ""
            // Set the back button title
            let backButton = UIBarButtonItem()
            backButton.title = "Back"
            navigationItem.backBarButtonItem = backButton
            
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            
            if #available(iOS 10.0, *) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    contactVC.navigationController?.setNavigationBarHidden(false, animated: false)
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.navigationController?.pushViewController(contactVC, animated: false)
            }
        }
    }
}
