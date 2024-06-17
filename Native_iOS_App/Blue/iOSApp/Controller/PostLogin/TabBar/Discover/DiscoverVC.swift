//
//  DiscoverVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import AlamofireImage
import Alamofire
import FirebaseCrashlytics
import LinkPresentation
import Lottie
import CoreBluetooth

class DiscoverVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var btnScan                              : UIButton!
    @IBOutlet weak var imgIncompleteProfileBtnScan          : UIImageView!
    @IBOutlet weak var imgProfile                           : CustomImage!
    @IBOutlet weak var imgIncompleteProfile                 : UIImageView!
    @IBOutlet weak var btnBLEOnOff                          : UIButton!
    @IBOutlet weak var lblAllNearUser                       : UILabel!
    @IBOutlet weak var lblHelloName                         : UILabel!
    @IBOutlet weak var btnHelloName                         : UIButton!
    @IBOutlet weak var lblUserNearby                        : UILabel!
    @IBOutlet weak var viewRadar                            : LottieAnimationView!
    @IBOutlet weak var viewCircleBoundary                   : CustomView!
    @IBOutlet weak var stackMoreUser                        : UIStackView!
    @IBOutlet weak var btnSeeMoreProfile                    : UIButton!
    @IBOutlet weak var viewMoreUser1                        : UIView!
    @IBOutlet weak var imgMoreUser1                         : UIImageView!
    @IBOutlet weak var viewMoreUser2                        : UIView!
    @IBOutlet weak var imgMoreUser2                         : UIImageView!
    @IBOutlet weak var viewMoreUser3                        : UIView!
    @IBOutlet weak var imgMoreUser3                         : UIImageView!
    @IBOutlet weak var viewMoreUser4                        : UIView!
    @IBOutlet weak var lblMoreUserCount                     : UILabel!
    @IBOutlet weak var viewProfile                          : UIView!
    @IBOutlet weak var viewMain                             : UIView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    private var nearByUserDetail                = UserDetail()
    private var bubbleTag                       = 1000
    private var bubbleRadius                    = 0
    private var arrFarPositions                 = [Position]()
    private let interactor                      = Interactor()
    private var viewCenterPoint                 : CGPoint!
    private var timer                           : Timer!
    private var metaData                        : LPLinkMetadata = LPLinkMetadata() {
        didSet {
            DispatchQueue.main.async {
                self.shareUserProfileURLWithMetadata(metaData: self.metaData)
            }
        }
    }
    
    private var timerCount                      = 10
    private let animationTimer                  = RepeatingTimer(timeInterval: 1)
    private var isFirstTime                     : Bool = true
    private var businessFirstname = ""
    private var businessLastname = ""
    //private var iconImageView: UIImageView?
    
    // Bubble Properties
    private var arrDegreeList: [Int]            = [0, 51, 102, 153, 204, 255, 306]
    private var arrBubble                       = [Bubble]()
    private var arrBeacon                       = [Beacon]()
    private var arr7PlusList                    = [Beacon]()
    private var arr7BubbleInView                = [Beacon]()
    
    private var viewCaption                     : UIView?
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DiscoverVC :: viewDidLoad")
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.lblHelloName.bounds
        gradientLayer.colors = [UIColor.appBlueGradient1_495AFF().cgColor, UIColor.appBlueGradient2_0ACFFE().cgColor]
        
        // Create an image with the gradient
        UIGraphicsBeginImageContextWithOptions(self.lblHelloName.frame.size, false, 0.0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Set the gradient image as the text color mask
        self.lblHelloName.textColor = UIColor(patternImage: gradientImage!)
        
        // Add observers for app state changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.addNotificationCenterObserver()
        
        if let oneIndex = arrAccount.lastIndex(where: { oneAccountData in
            return oneAccountData[APIParamKey.kUserId] as? String == UserLocalData.UserID
        }) {
            
            if UserLocalData.userMode == "0" {
                
                arrAccount[oneIndex][APIParamKey.kProfilePic] = loginUser?.profile_img
                arrAccount[oneIndex][APIParamKey.kName] = loginUser?.name
                UserLocalData.arrOfAccountData = arrAccount
                
            } else {
                
                let profilePic = loginUser?.business_profileURL != nil && loginUser?.business_profileURL != "" ? loginUser?.business_profileURL : loginUser?.profile_img
                arrAccount[oneIndex][APIParamKey.kProfilePic] = profilePic
                arrAccount[oneIndex][APIParamKey.kName] = loginUser?.business_firstName != nil && loginUser?.business_firstName != "" && loginUser?.business_lastName != nil && loginUser?.business_lastName != "" ? (loginUser?.business_firstName)! + " " + (loginUser?.business_lastName)! : loginUser?.name
                
                UserLocalData.arrOfAccountData = arrAccount
            }
        }
        
        self.callGetInfoAndGetBusinessProfileAPI()
        
        //appDelegate.registerForPushNotification(application: UIApplication.shared)
        appDelegate.setUpOneSignalNotification(launchOptions: oneSignalLaunchOption)
        
        self.setNotificationDelegate()
        
        BLEManager.shared.delegate = self
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("DiscoverVC :: viewWillAppear")
        
        self.btnBLEOnOff.isSelected = false
        
        LocationManager.shared.checkLocationAuthorization()
        LocationManager.shared.setupLocationManager()
        
        // Check Bluetooth permission status
        BLEManager.shared.checkBluetoothPermissionAndState { isPermissionGranted in
            if isPermissionGranted {
                print("Bluetooth permission granted")
            } else {
                print("Bluetooth permission denied")
                // Handle permission denied scenario here
                BLEManager.shared.handleAuthorizationRestriction()
            }
        }
        
        BLEManager.shared.getBluetoothState { isON in
            
            print("isBluetoothON :: \(isON)")
            print("isBLEPermissionGiven:", BLEManager.shared.isBLEPermissionGiven)
            if isON {
                self.bleBtnOnAction()
            } else {
                self.showAlertWithOKButton(message: kTurnOnBluetooth)
                self.bleBtnOffAction()
            }
        }
        
        if BLEManager.shared.isBLEPermissionGiven == true && BLEManager.shared.isBluetoothON == true && UserLocalData.isbtnBLEOn == true {
            self.bleBtnOnAction()
        } else {
            self.btnBLEOnOff.setImage(UIImage(named: "ic_bluetooth"), for: .normal)
            self.bleBtnOffAction()
        }
        self.showHideLabelNoNearByUser()
        self.setUserDataOnDasboardScreen()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            self.viewMoreUser1.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isFirstTime {
            
            if let mainTabBarController = self.tabBarController as? MainTabbarController {
                
                let isFromRegister = mainTabBarController.isFromRegister
                // Now, you have the value of isFromRegister and can use it in DiscoverVC.
                
                if isFromRegister {
                    
                    print("Display Welcome Gift")
                    
                    let welcomeGiftVC = WelcomeGiftVC.instantiate(fromAppStoryboard: .Login)
                    welcomeGiftVC.modalTransitionStyle = .crossDissolve
                    welcomeGiftVC.modalPresentationStyle = .overCurrentContext
                    self.present(welcomeGiftVC, animated: false)
                }
            }
        }
        
        self.isFirstTime = false
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
        // Remove observers in your view controller's lifecycle (e.g., in deinit)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    // Selector method called when the app enters the foreground
    @objc func appWillEnterForeground() {
        
        print("appWillEnterForeground")
        
        // Schedule the timer when the app enters the foreground
        self.scheduleTimer()
    }
    
    // Selector method called when the app enters the background
    @objc func appDidEnterBackground() {
        
        print("appDidEnterBackground")
        
        // Invalidate the timer when the app enters the background
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @IBAction func onBtnScan(_ sender: UIButton) {
        
        if loginUser?.username == "" || loginUser?.username == nil || loginUser?.profile_img == "" || loginUser?.profile_img == nil { // Incomplete Profile
            
            let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
            finishProfileVC.modalTransitionStyle = .crossDissolve
            finishProfileVC.modalPresentationStyle = .overCurrentContext
            self.present(finishProfileVC, animated: true)
            
        } else { // Completed Profile
            
            let scanQRCodeVC = ScanQRCodeVC.instantiate(fromAppStoryboard: .Discover)
            self.navigationController?.pushViewController(scanQRCodeVC, animated: true)
        }
    }
    
    @IBAction func onBtnHelloName(_ sender: UIButton) {
        
        print("Button Hello Tapped")
        let filterInterestsVC = FilterInterestsVC.instantiate(fromAppStoryboard: .Discover)
        filterInterestsVC.modalTransitionStyle = .crossDissolve
        filterInterestsVC.modalPresentationStyle = .overCurrentContext
        filterInterestsVC.isFromInterestVC = false
        self.present(filterInterestsVC, animated: false)
    }
    
    // Self Profile
    @IBAction func onBtnMyProfile(_ sender: UIButton) {
        
        if loginUser?.username == "" || loginUser?.username == nil || loginUser?.profile_img == "" || loginUser?.profile_img == nil { // Incomplete Profile
            
            let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
            finishProfileVC.modalTransitionStyle = .crossDissolve
            finishProfileVC.modalPresentationStyle = .overCurrentContext
            self.present(finishProfileVC, animated: true)
            
        } else { // Completed Profile
            
            let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            profileVC.navigationScreen = .currentUserProfile
            profileVC.delegate = self
            
            // Use a custom transition
            let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromTop
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            
            self.navigationController?.pushViewController(profileVC, animated: false)
        }
    }
    
    @IBAction func onBtnBLEOnOFF(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if self.btnBLEOnOff.isSelected && BLEManager.shared.isBLEPermissionGiven == true && sender.isSelected && BLEManager.shared.centralManager.state == .poweredOn {
            
            self.bleBtnOnAction()
            
        } else {
            
            if BLEManager.shared.isBLEPermissionGiven == false {
                
                BLEManager.shared.handleAuthorizationRestriction()
                
            } else {
                
                if BLEManager.shared.centralManager.state == .poweredOff  {
                    
                    self.showAlertWithOKButton(message: kTurnOnBluetooth)
                }
                
                self.bleBtnOffAction()
            }
        }
    }
    
    private func bleBtnOnAction() {
        
        UserLocalData.isbtnBLEOn = true
        self.btnBLEOnOff.isSelected = true
        self.btnBLEOnOff.setImage(UIImage(named: "ic_bluetooth_on"), for: .normal)
        self.startLottieAnimationInRadarView()
        self.startBLEAdvertisementAndScanning()
        self.viewCaption?.isHidden = false
        
        UserLocalData.isNetworkmode = true
        stackMoreUser.isHidden = false
        NotificationCenter.default.post(name: .nearByOn, object: UserLocalData.isNetworkmode, userInfo: nil)
        
        if UIDevice.isSimulator == false { self.showNearByUser() }
    }
    
    private func bleBtnOffAction() {
        
        UserLocalData.isbtnBLEOn = false
        self.btnBLEOnOff.isSelected = false
        self.btnBLEOnOff.setImage(UIImage(named: "ic_bluetooth"), for: .normal)
        self.stopLottieAnimationInRadarView()
        BLEPeripherals.shared.stopAdvertise()
        BLEManager.shared.stopScanning()
        self.viewCaption?.isHidden = true
        
        UserLocalData.isNetworkmode = false
        NotificationCenter.default.post(name: .nearByOn, object: UserLocalData.isNetworkmode, userInfo: nil)
        
        for arr in self.arrBubble {
            self.viewRadar.viewWithTag(arr.tag)?.removeFromSuperview()
        }
        
        self.arrBeacon.removeAll()
        self.arrBubble.removeAll()
        self.arr7BubbleInView.removeAll()
        self.arr7PlusList.removeAll()
        
        self.showHideLabelNoNearByUser()
        
        self.stackMoreUser.isHidden = true
        self.lblAllNearUser.isHidden = true
        self.imgMoreUser1.image = nil
        self.viewMoreUser1.isHidden = true
        self.imgMoreUser2.image = nil
        self.viewMoreUser2.isHidden = true
        self.imgMoreUser3.image = nil
        self.viewMoreUser3.isHidden = true
        self.viewMoreUser4.isHidden = true
        self.lblMoreUserCount.text = ""
        self.viewCircleBoundary.subviews.forEach { $0.removeFromSuperview() }
    }
    
    @IBAction func onBtnSeeMoreProfile(_ sender: UIButton) {
        
        var beacons = [Beacon]()
        beacons = self.arrBeacon
        let viewMoreVC = ViewMoreUserVC.instantiate(fromAppStoryboard: .Discover)
        // Set the beacons property on the correct instance
        viewMoreVC.arrBeacons = beacons
        // Use a custom transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(viewMoreVC, animated: false)
    }
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension DiscoverVC {
    
    // callGetInfoAPI to get details of nearByUser
    //    private func getNearByUserSocialInfo(nearByUserID: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
    //
    //        self.callGetInfoAPI(UserID: nearByUserID) { isSuccess, response in
    //
    //            if let getInfoAPIResponse = response {
    //
    //                if getInfoAPIResponse.user_mode == "1" && getInfoAPIResponse.subscriptionStatus == "1" {
    //
    //                    self.callGetBusinessProfileAPI(UserID: nearByUserID) { isSuccess, response in
    //
    //                        if let getBusinessProfileAPIResponse = response {
    //
    //                            self.setNearByUserSocialInfo(userDetail: getBusinessProfileAPIResponse)
    //                            self.nearByUserDetail = getBusinessProfileAPIResponse
    //                            completion(isSuccess)
    //                        }
    //                    }
    //
    //                } else {
    //
    //                    self.setNearByUserSocialInfo(userDetail: getInfoAPIResponse)
    //                    self.nearByUserDetail = getInfoAPIResponse
    //                    completion(isSuccess)
    //                }
    //            }
    //        }
    //    }
    
    private func getNearByUserSocialInfo(nearByUserID: String, bleDevice: BLEDevice, completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        self.callGetUserInfoAPI(nearByUserID: nearByUserID) { isSuccess, response in
            
            if var getInfoAPIResponse = response {
                
                //self.setUserSocialInfoInDB(userID: nearByUserID, userJSON: getInfoAPIResponse.toJSONString()!)
                getInfoAPIResponse.peripheralUUID = bleDevice.uuid
                self.setNearByUserSocialInfo(userDetail: getInfoAPIResponse)
                self.nearByUserDetail = getInfoAPIResponse
                completion(isSuccess)
            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - Function -
// ----------------------------------------------------------
extension DiscoverVC {
    
    // Method to schedule the timer
    private func scheduleTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
    }
    
    // Selector method called when the timer fires
    @objc func timerFired() {
        
        // Check if the app is in the foreground
        if UIApplication.shared.applicationState == .active {
            // Call your method only when the app is in the foreground
            self.setAllBubbles()
        }
    }
    
    private func addNotificationCenterObserver() {
        
        NotificationCenter.default.removeObserver(self, name: .businessCardUser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadBusinessVisitingUser(_:)), name: .businessCardUser, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .nearByOn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.BtnBLEOn(notification:)), name: .nearByOn, object: nil)
    }
    
    @objc private func loadBusinessVisitingUser(_ notification: NSNotification) {
        
        //guard let businessCardUserID = notification.object as? String else { return }
    }
    
    @objc func BtnBLEOn(notification: Notification) {
        
        if UIDevice.isSimulator == false { self.showNearByUser() }
    }
    
    private func startLottieAnimationInRadarView() {
        
        self.startTimer()
        self.viewRadar.loopMode = .loop
        self.viewRadar.animationSpeed = 1.0
        self.viewRadar.play()
    }
    
    private func stopLottieAnimationInRadarView() {
        
        self.viewRadar.loopMode = .loop
        self.viewRadar.pause()
        self.viewRadar.stop()
    }
    
    private func startTimer() {
        
        self.timerCount = 10
        
        self.animationTimer.eventHandler = {
            DispatchQueue.main.async {
                self.timerCall()
            }
        }
        self.animationTimer.resume()
    }
    
    private func timerCall() {
        
        if self.timerCount >= 0 {
            self.timerCount -= 1
        } else {
            self.stopTimer()
        }
    }
    
    private func stopTimer() {
        
        self.animationTimer.suspend()
        self.timerCount = 10
    }
    
    private func startBLEAdvertisementAndScanning() {
        
        //self.btnBLEOnOff.alpha = 0.5
        self.btnBLEOnOff.isUserInteractionEnabled = false
        
        if let int64DeviceName = Int64(UserLocalData.UserID) {
            
            print("Current UserID converted to Int64 Successfully, int64DeviceName: \(int64DeviceName)")
            let encodedDeviceName = UserIDEncoder().encode(userId: int64DeviceName)
            print("Current User's encodedDeviceName: \(encodedDeviceName)")
            
            BLEPeripherals.shared.startAdvertising(name: encodedDeviceName) { isSuccess, msg, error in
                
                //self.btnBLEOnOff.alpha = 1
                self.btnBLEOnOff.isUserInteractionEnabled = true
                
                if isSuccess {
                    print(":: BLEPeripherals Advertising Started ::")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        self.startBLEScanning()
                    })
                }
            }
            
        } else {
            print("Current UserID Failed to convert to Int64")
        }
    }
    
    private func startBLEScanning() {
        
        BLEManager.shared.startScanning(services: [SERVICES.ADVERTISEMENT_DISCOVER_SERVICE_UUID]) { bleDevice, msg, isNew in
            
            //print(":: BLE Scanning callback ::")
            
            //print("bleDevice: \(bleDevice)")
            //print("msg: \(msg)")
            //print("isNew: \(isNew)")
            
            if let foundUserID = bleDevice.localName ?? bleDevice.name {
                
                //print("Found BLE Device localName: \(bleDevice.localName ?? "")")
                //print("Found BLE Device name: \(bleDevice.name ?? "")")
                
                if foundUserID.count <= 5 {
                    
                    let decodedInt64DeviceName = UserIDEncoder().decode(encoded: foundUserID)
                    //print("Nearby UserID decode to Int64 Successfully, decodedDeviceName: \(decodedInt64DeviceName)")
                    
                    if "\(decodedInt64DeviceName)" != UserLocalData.UserID &&  self.btnBLEOnOff.isSelected == true {
                        
                        if DBManager.checkUserSocialInfoExist(userID: "\(decodedInt64DeviceName)").isSuccess {
                            
                            var userDetail = DBManager.getUserData(userID: "\(decodedInt64DeviceName)")
                            userDetail?.peripheralUUID = bleDevice.uuid
                            self.setNearByUserSocialInfo(userDetail: userDetail)
                            
                        } else {
                            
                            if isNew {
                                self.getNearByUserSocialInfo(nearByUserID: "\(decodedInt64DeviceName)", bleDevice: bleDevice) { isSuccess in
                                }
                            }
                        }
                    }
                }
            }
            
            for beacon in self.arrBeacon {
                
                if self.arrBeacon.count < 8 {
                    
                    // Check if the beacon with the same uuid exists in arr7BubbleInView
                    let beaconExists = self.arr7BubbleInView.contains { $0.uuid == beacon.uuid }
                    if !beaconExists {
                        self.arr7BubbleInView.append(beacon)
                        print("Beacon added in arr7BubbleInView", beacon)
                        print("arr7BubbleInView count =", self.arr7BubbleInView.count)
                    }
                    
                } else {
                    
                    // Check if the beacon with the same uuid exists in arr7BubbleInView
                    let beaconExistsInBubble = self.arr7BubbleInView.contains { $0.uuid == beacon.uuid }
                    if !beaconExistsInBubble {
                        // Check if the beacon with the same uuid exists in arr7PlusList
                        let beaconExistsInPlusList = self.arr7PlusList.contains { $0.uuid == beacon.uuid }
                        if !beaconExistsInPlusList {
                            self.arr7PlusList.append(beacon)
                            print("Beacon added in arr7PlusList", beacon)
                            print("arr7PlusList count =", self.arr7PlusList.count)
                            self.updateSeeMoreUserView(arr: self.arr7PlusList)
                            self.lblAllNearUser.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    private func callGetInfoAndGetBusinessProfileAPI() {
        
        self.callGetInfoAPI(needToShowAlertForFailure: false, isFromLoginRegister: true, UserID: UserLocalData.UserID) { isSuccess, response in
            
            if isSuccess {
                
                if let getInfoAPIResponse = response {
                    
                    if response?.subscriptionStatus == "0" {
                        
                        UserLocalData.userMode = "0"
                        loginUser = getInfoAPIResponse
                        loginUser?.social_network = getInfoAPIResponse.social_network
                        
                        if let profile = loginUser {
                            self.setUserProfileImage(profile: profile, userMode: "0")
                        }
                    }
                }
            }
        }
    }
    
    private func showHideLabelNoNearByUser() {
        
        if self.arrBeacon.count > 0 {
            self.lblUserNearby.isHidden = true
        } else {
            self.lblUserNearby.isHidden = false
        }
    }
    
    private func showNearByUser() {
        
        if UserLocalData.UserID != "" {
            
            self.initialSetup()
            
            // If the internet is available, starts scanning for beacons using beaconManager and updates the array of beacons (arrBeacon)
            
            // Check for internet availability
            guard isInternetAvailable else {
                self.showAlertWithOKButton(message: kPlease_connect_Internet)
                return
            }
            
            // Invalidate the timer if it exists
            if let timer = self.timer {
                timer.invalidate()
            }
            
            // TODO: As should not call setBeaconBubbles When app is in BG, commented below code and Implemented Notification Observer by adding appDidEnterForeground and appDidEnterBackground Selector method
            // setup a timer to perform a specific function (setAllBubbles) repeatedly every 6 seconds.
            self.timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.setAllBubbles), userInfo: nil, repeats: true)
            
        } else {
            
            // If UserLocalData.UserID == "" (the user is not logged in), it clears and stops various components related to nearby users.
            for arr in self.arrBubble {
                self.viewRadar.viewWithTag(arr.tag)?.removeFromSuperview()
            }
            
            self.arrBeacon.removeAll()
            self.arrBubble.removeAll()
        }
    }
    
    @objc func setAllBubbles() {
        
        self.unReservedAllBubbles()
        
        if self.arrBeacon.count > 0 {
            self.setBeaconBubbles(bubbleIndex: 0)
        }
    }
    
    private func unReservedAllBubbles() {
        
        for pos in self.arrFarPositions {
            pos.isReserved = false
            pos.tag = -1
        }
    }
    
    private func initialSetup() {
        
        self.bubbleRadius = Int((self.viewRadar.frame.width / 6))
        self.setXYPositions()
    }
    
    private func setUserDataOnDasboardScreen() {
        
        if UserLocalData.UserID == "" { return }
        
        self.getLoginUserDataFromDB(userMode: UserLocalData.userMode) { isSuccess, response in
            
            if let profile = response {
                
                if profile.subscriptionStatus == "0" || profile.user_mode == "0" {
                    self.setUserProfileImage(profile: profile, userMode: "0")
                    
                } else {
                    self.setUserProfileImage(profile: profile, userMode: "1")
                }
            }
        }
    }
    
    private func setUserProfileImage(profile: UserDetail, userMode: String) {
        
        DispatchQueue.main.async {
            
            var myProfileImage = ""
            
            if userMode == "0" {
                myProfileImage = profile.profile_img ?? ""
                
            } else if userMode == "1" {
                myProfileImage = profile.business_profileURL ?? (profile.profile_img ?? "")
            }
            
            if let existingCaptionView = self.viewCaption {
                existingCaptionView.removeFromSuperview() // Remove the existing caption view
            }
            
            if let caption = profile.caption, !caption.isEmpty, self.btnBLEOnOff.isSelected == true {
                // Add new caption view if caption is not empty
                self.viewProfile.sizeToFit()
                self.viewCaption = self.setCaptionView(labelText: caption, frame: self.viewProfile.frame)
                self.viewMain.addSubview(self.viewCaption ?? UIView())
            }
            
            let url = URL(string: myProfileImage)
            
            if let profileURL = url {
                
                // Completed Profile
                print("Profile is Completed")
                self.imgIncompleteProfile.isHidden = true
                self.imgIncompleteProfileBtnScan.isHidden = true
                
                print("profileURL = \(profileURL)")
                self.imgProfile.af_setImage(withURL: profileURL)
                
            } else {
                
                // Incomplete Profile | FinishProfileVC | Red Icon
                print("Profile is Incomplete")
                self.imgIncompleteProfile.isHidden = false
                self.imgIncompleteProfileBtnScan.isHidden = false
                
                self.imgProfile.image = UIImage.imageWithInitial(initial: "\(profile.firstname?.capitalized.first ?? "A")\( profile.lastname?.capitalized.first ?? "B")", imageSize: self.imgProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            }
            
            // Force layout update
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func setXYPositions() {
        
        var x = Int(self.viewCircleBoundary.frame.origin.x)
        
        while x < Int((self.viewCircleBoundary.frame.origin.x + self.viewCircleBoundary.frame.width)) {
            let y = self.viewCircleBoundary.frame.origin.y
            let pos = Position()
            pos.xPosition = x
            pos.yPosition = Int(y)
            pos.isReserved = false
            self.arrFarPositions.append(pos)
            x += 79
        }
        
        x = Int(self.viewCircleBoundary.frame.origin.x)
        
        while x < Int((self.viewCircleBoundary.frame.origin.x + self.viewCircleBoundary.frame.width)) {
            let y = self.viewCircleBoundary.frame.origin.y + self.viewCircleBoundary.frame.height
            let pos = Position()
            pos.xPosition = x
            pos.yPosition = Int(y)
            pos.isReserved = false
            self.arrFarPositions.append(pos)
            x += 79
        }
        
        var y = Int(self.viewCircleBoundary.frame.origin.y)
        
        while y < Int((viewCircleBoundary.frame.origin.y + self.viewCircleBoundary.frame.height)) {
            let x = self.viewCircleBoundary.frame.origin.x
            let pos = Position()
            pos.xPosition = Int(x)
            pos.yPosition = Int(y)
            pos.isReserved = false
            self.arrFarPositions.append(pos)
            y += 110
        }
        
        y = Int(self.viewCircleBoundary.frame.origin.y)
        
        while y < Int((self.viewCircleBoundary.frame.origin.y + self.viewCircleBoundary.frame.height)) {
            let x = self.viewCircleBoundary.frame.origin.x + self.viewCircleBoundary.frame.width
            let pos = Position()
            pos.xPosition = Int(x)
            pos.yPosition = Int(y)
            pos.isReserved = false
            self.arrFarPositions.append(pos)
            y += 110
        }
    }
    
    private func setNearByUserSocialInfo(userDetail: UserDetail?) {
        
        let userBeaconDetail = ["major": "\(Int.random(in: 1000...9999))", "minor": "\(Int.random(in: 1000...9999))", "title": userDetail!.firstname?.capitalizingFirstLetter() ?? "", "uuid": userDetail?.id ?? "", "favicon": userDetail?.profile_img ?? ""] as [String: Any]
        
        let beaconDetail = Beacon(JSON: userBeaconDetail as [String: Any])
        beaconDetail?.avgRssi = Int.random(in: -100 ..< -60)
        beaconDetail?.beaconid = userDetail?.id
        beaconDetail?.descriptionField = "Someone's nearby"
        beaconDetail?.userDetail = userDetail
        beaconDetail?.isBeacon = false
        beaconDetail?.isTapSocial = false
        beaconDetail?.distanceInMeter = userDetail?.distanceInMeter
        beaconDetail?.timeStamp = Date().timeIntervalSince1970 * 1000
        beaconDetail?.peripheralUUID = userDetail?.peripheralUUID
        
        //for beacons
        if let foundBeaconIndex = self.arrBeacon.firstIndex(where: { (beacon) -> Bool in
            return beacon.uuid == userDetail?.id
        }) {
            
            // Update
            let currentTimeStamp = Date().timeIntervalSince1970 * 1000
            let timeInterval = currentTimeStamp - self.arrBeacon[foundBeaconIndex].timeStamp
            
            //print("timeInterval = \(timeInterval)")
            
            if timeInterval > 3000 {
                self.arrBeacon[foundBeaconIndex].distanceInMeter = userDetail?.distanceInMeter
                self.arrBeacon[foundBeaconIndex].timeStamp = Date().timeIntervalSince1970 * 1000
                //self.setBeaconBubbles(objBeacon: self.arrBeacon[foundBeaconIndex])
            }
            
        } else {
            
            // Fill arrBeacon
            self.arrBeacon.append(beaconDetail!)
            //self.setBeaconBubbles(objBeacon: beaconDetail!)
            
            for obj in self.arrBeacon {
                print("setNearByUserSocialInfo :: peripheralUUID", obj.peripheralUUID ?? "")
            }
            
            //To generate local Notification when get first BLE Device
            if self.arrBeacon.count == 1 {
                BLEManager.shared.generateNotification(beacon: self.arrBeacon[0])
            }
        }
    }
    
    private func postBLEInteraction(userData: UserDetail?) {
        
        DispatchQueue.main.async {
            
            // To add nearByUser in Interactions List
            self.callDeviceScanAPI(scanType: BLEDeviceScanType.Missed.rawValue,
                                   NFCURL: "",
                                   receiverID: userData?.id ?? "",
                                   lat: LocationManager.shared.locationManager?.location?.coordinate.latitude ?? 0.0,
                                   lng: LocationManager.shared.locationManager?.location?.coordinate.longitude ?? 0.0)
        }
    }
    
    private func calculateDegreeIndex(bubbleIndex: Int) -> Int {
        
        let petalCount = 7
        return bubbleIndex % petalCount
    }
    
    private func setBeaconBubbles(bubbleIndex: Int) {
        
        let beacon = self.arrBeacon[bubbleIndex]
        
        if self.getIndexOfbubble(beacon: beacon) == nil {
            
            if let frame = getBubbleFrame(beacon: beacon) {
                self.createBubbleForBeacon(frame: frame, beacon: beacon)
                self.timerFired()
                //print("Creating Bubble....")
            } else {
                print("Unable find frame for bubble")
            }
            
        } else {
            
            if self.getBubbleFrame(beacon: beacon) != nil {
                
                let center = CGPoint(x: self.viewCircleBoundary.bounds.midX, y: self.viewCircleBoundary.bounds.midY)
                let radius = viewCircleBoundary.frame.size.width / 2.65 // Adjust this as neede
                
                for (index, view) in self.viewCircleBoundary.subviews.enumerated() {
                    let degree = arrDegreeList[calculateDegreeIndex(bubbleIndex: index)]
                    let angle = CGFloat(degree) * .pi / 180.0
                    
                    let bubbleX = center.x + CGFloat(radius) * cos(angle)
                    let bubbleY = center.y + CGFloat(radius) * sin(angle)
                    
                    view.frame.origin = CGPoint(x: bubbleX - CGFloat(bubbleRadius / 2), y: bubbleY - CGFloat(bubbleRadius / 2) - 5)
                }
            }
        }
        
        if bubbleIndex != (self.arrBeacon.count - 1) {
            if arrBubble.count < 7 {
                self.setBeaconBubbles(bubbleIndex: bubbleIndex + 1)
            }
        }
    }
    
    private func getIndexOfbubble(beacon: Beacon) -> Int? {
        
        var bubbleIndex: Int?
        
        for (index, bubble) in self.arrBubble.enumerated() {
            
            if ((bubble.uuid == beacon.uuid) && (bubble.major == beacon.major) && (bubble.minor == beacon.minor)) {
                bubbleIndex = index
                break
            }
        }
        
        return bubbleIndex
    }
    
    private func getBubbleFrame(beacon: Beacon) -> CGRect? {
        
        //let newRssi = beacon.avgRssi
        var frame: CGRect!
        
        let tag = self.arrBubble.filter { (bubble) -> Bool in
            return beacon.uuid == bubble.uuid && beacon.major == bubble.major && beacon.minor == bubble.minor
        }
        let farPositions = self.arrFarPositions.filter { (pos) -> Bool in
            return pos.isReserved == false
        }
        
        if farPositions.count == 0 {
            frame = nil
            
        } else {
            let pos = farPositions.randomElement()
            pos!.isReserved = true
            pos?.tag = tag.count > 0 ? tag[0].tag : 0
            frame = CGRect(x: pos!.xPosition, y: pos!.yPosition, width: bubbleRadius, height: bubbleRadius)
        }
        return frame
    }
    
    private func setBubbleImageForMoreUser(beacon: Beacon, imageView: UIImageView) {
        
        self.initialsLabel.font = UIFont(name: "RedHatDisplay-Medium", size: 6) ?? UIFont.boldSystemFont(ofSize: 6)
        
        if beacon.userDetail?.user_mode == "1" && beacon.userDetail?.subscriptionStatus == "1" {
            
            if let url = URL(string: beacon.userDetail?.business_profileURL ?? "") {
                
                imageView.af_setImage(withURL: url)
                
            } else {
                
                if let firstName = beacon.userDetail?.business_firstName?.capitalized.first {
                    self.businessFirstname = String(firstName)
                    
                } else if let firstName = beacon.userDetail?.firstname?.capitalized.first {
                    self.businessFirstname = String(firstName)
                }
                
                if let lastName = beacon.userDetail?.business_lastName?.capitalized.first {
                    self.businessLastname = String(lastName)
                    
                } else if let lastName = beacon.userDetail?.lastname?.capitalized.first {
                    self.businessLastname = String(lastName)
                }
                
                imageView.image = UIImage.imageWithInitial(initial: "\(self.businessFirstname)\(self.businessLastname)", imageSize: imageView.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 6) ?? UIFont.boldSystemFont(ofSize: 6))
            }
            
        } else {
            
            if let url = URL(string: beacon.userDetail?.profile_img ?? "") {
                
                imageView.af_setImage(withURL: url)
                
            } else {
                
                imageView.image = UIImage.imageWithInitial(initial: "\(beacon.userDetail?.firstname?.capitalized.first ?? "A")\(beacon.userDetail?.lastname?.capitalized.first ?? "B")", imageSize: imageView.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 6) ?? UIFont.boldSystemFont(ofSize: 6))
            }
        }
    }
    
    private func createBubbleForBeacon(frame: CGRect, beacon: Beacon) {
        
        let newframe = CGRect(x: frame.origin.x + 30, y: frame.origin.y + 30, width: frame.width, height: frame.height + 30)
        var viewCaptionNearbyUser = UIView()
        
        let beaconView = UIView(frame: newframe)
        beaconView.tag = bubbleTag
        beaconView.clipsToBounds = true
        
        // let panGesture = UIPanGestureRecognizer()
        // beaconView.addGestureRecognizer(panGesture)
        // panGesture.addTarget(self, action: #selector(moveCenterView(gesture:)))
        
        //var isCaptionEnable = false
        if let caption = beacon.userDetail?.caption, !caption.isEmpty {
            
            //isCaptionEnable = true
            
            // Create and add the caption view
            viewCaptionNearbyUser = self.setCaptionView(labelText: beacon.userDetail?.caption ?? "", frame: newframe)
            viewCaptionNearbyUser.frame.origin.x = (beaconView.frame.size.width / 2) - (viewCaptionNearbyUser.frame.width / 2)
            //Add -5 because uiimage have 5 distance from view // and 12 id for bottom tringle for caption view
            viewCaptionNearbyUser.frame.origin.y = -(viewCaptionNearbyUser.frame.size.height + (12 - 5))
            // viewCaptionNearbyUser.frame.origin.y = 0
            
            beaconView.addSubview(viewCaptionNearbyUser )
            // beaconView.frame.size.height = beaconView.frame.size.height + viewCaptionNearbyUser.frame.size.height + 12
        }
        
        beaconView.clipsToBounds = false
        
        let imgWidth = frame.width
        let imgBeacon = UIImageView(frame: CGRect(x: 0, y: 5, width: imgWidth, height: imgWidth))
        
        //        let iconImageViewY = beaconView.frame.height - 45
        //        self.iconImageView = UIImageView(frame: CGRect(x: beaconView.frame.width - 25, y: iconImageViewY , width: 20, height: 20))
        
        let iconImageView = UIImageView(frame: CGRect(x: beaconView.frame.width - 25, y: beaconView.frame.height - 45, width: 20, height: 20))
        imgBeacon.layer.borderColor = UIColor.appWhite_FFFFFF().cgColor
        imgBeacon.layer.borderWidth = 1
        print("Beacon ID :: ", beacon.id ?? "")
        if beacon.userDetail?.user_mode == "1" && beacon.userDetail?.subscriptionStatus == "1" {
            
            if let url = URL(string: beacon.userDetail?.business_profileURL ?? "") {
                
                imgBeacon.af_setImage(withURL: url)
                
                if beacon.userDetail?.business_username != nil || beacon.userDetail?.business_username != "" {
                    iconImageView.isHidden = true
                    
                } else {
                    iconImageView.isHidden = false
                }
                
            } else {
                
                iconImageView.isHidden = false
                
                if let firstName = beacon.userDetail?.business_firstName?.capitalized.first {
                    self.businessFirstname = String(firstName)
                    
                } else if let firstName = beacon.userDetail?.firstname?.capitalized.first {
                    self.businessFirstname = String(firstName)
                }
                
                if let lastName = beacon.userDetail?.business_lastName?.capitalized.first {
                    self.businessLastname = String(lastName)
                    
                } else if let lastName = beacon.userDetail?.lastname?.capitalized.first {
                    self.businessLastname = String(lastName)
                }
                
                imgBeacon.image = UIImage.imageWithInitial(initial: "\(self.businessFirstname)\(self.businessLastname)", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            }
            
        } else {
            
            if let url = URL(string: beacon.userDetail?.profile_img ?? "") {
                
                imgBeacon.af_setImage(withURL: url)
                
                if beacon.userDetail?.username != nil || beacon.userDetail?.username != ""  {
                    iconImageView.isHidden = true
                    
                } else {
                    iconImageView.isHidden = false
                }
                
            } else {
                
                iconImageView.isHidden = false
                
                imgBeacon.image = UIImage.imageWithInitial(initial: "\(beacon.userDetail?.firstname?.capitalized.first ?? "A")\(beacon.userDetail?.lastname?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            }
        }
        imgBeacon.layer.cornerRadius = imgWidth / 2
        imgBeacon.contentMode = .scaleAspectFill
        imgBeacon.clipsToBounds = true
        imgBeacon.layer.borderWidth = 2.6
        imgBeacon.layer.borderColor = UIColor.white.cgColor
        
        iconImageView.image = UIImage(named: "ic_incomplete_profile")
        iconImageView.contentMode = .scaleAspectFit
        
        let lblBeaconY = 5 + imgWidth
        let lblBeaconheight = (beaconView.frame.height - lblBeaconY)
        
        let lblBeacon = UILabel(frame: CGRect(x: 0, y: lblBeaconY , width: beaconView.frame.width, height: lblBeaconheight))
        
        lblBeacon.textColor = UIColor.appBlack_031227()
        lblBeacon.font = UIFont(name: "RedHatDisplay-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        lblBeacon.adjustsFontSizeToFitWidth = true
        lblBeacon.minimumScaleFactor = 0.8
        
        lblBeacon.text = beacon.title ?? ""
        lblBeacon.textAlignment = .center
        lblBeacon.clipsToBounds = true
        
        beaconView.addSubview(imgBeacon)
        beaconView.addSubview(lblBeacon)
        beaconView.addSubview(iconImageView)
        
        let btnBubble = UIButton(frame: beaconView.bounds)
        btnBubble.tag = Int(beacon.userDetail?.id ?? "\(self.bubbleTag)") ?? 0
        btnBubble.addTarget(self, action: #selector(self.onBtnNearByBubble(sender:)), for: .touchUpInside)
        btnBubble.clipsToBounds = true
        beaconView.addSubview(btnBubble)
        beaconView.tag = Int(beacon.userDetail?.id ?? "\(self.bubbleTag)") ?? 0
        
        self.viewCircleBoundary.addSubview(beaconView)
        
        let bubble = Bubble()
        bubble.tag = Int(beacon.userDetail?.id ?? "\(self.bubbleTag)") ?? 0
        bubble.uuid = beacon.uuid
        bubble.major = beacon.major
        bubble.minor = beacon.minor
        self.arrBubble.append(bubble)
        self.showHideLabelNoNearByUser()
        
        self.updateSeeMoreUserView(arr: arr7PlusList)
    }
    
    private func setCaptionView(labelText: String, frame: CGRect) -> UIView {
        
        let captionView = UIView()
        captionView.backgroundColor = .white
        captionView.layer.cornerRadius = 14
        captionView.layer.shadowColor = UIColor.black.cgColor
        captionView.layer.shadowOpacity = 0.1
        captionView.layer.shadowOffset = CGSize(width: 0, height: 1)
        captionView.layer.shadowRadius = 1
        
        let label = UILabel()
        label.text = labelText.count > 20 ? String(labelText.prefix(20)) + "..." : labelText
        label.numberOfLines = labelText.count > 20 ? 0 : 1
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont(name: "RedHatDisplay-Medium", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        label.frame.size.height = 20
        
        if (label.text?.count ?? 0) > 10 {
            label.numberOfLines = 2
            label.frame.size.width = 71
        }
        label.sizeToFit()
        label.frame = CGRect(x: 10, y: 10, width: label.frame.width, height: label.frame.height > 20 ? label.frame.height : 20)
        
        let captionViewWidth = label.frame.width + 20
        let captionViewHeight = label.frame.height + 20
        let beconviewMidPoint = frame.origin.x + ( frame.size.width / 2)
        let captionXPoint = beconviewMidPoint - (captionViewWidth / 2)
        
        captionView.frame = CGRect(x: captionXPoint , y: frame.origin.y - (captionViewHeight + 12), width: captionViewWidth, height: captionViewHeight)
        
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: captionViewWidth / 2 - 10, y: captionViewHeight))
        trianglePath.addLine(to: CGPoint(x: captionViewWidth / 2 + 10, y: captionViewHeight))
        trianglePath.addLine(to: CGPoint(x: captionViewWidth / 2, y: captionViewHeight + 10))
        trianglePath.close()
        
        let triangleLayer = CAShapeLayer()
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = UIColor.white.cgColor
        captionView.layer.addSublayer(triangleLayer)
        
        captionView.addSubview(label)
        
        return captionView
    }
    
    private func updateSeeMoreUserView(arr: [Beacon]) {
        
        var count = 0
        
        if arr.isEmpty {
            self.lblAllNearUser.isHidden = true
            self.btnSeeMoreProfile.isHidden = true
            self.btnSeeMoreProfile.isUserInteractionEnabled = false
            self.stackMoreUser.isHidden = true
        } else {
            self.lblAllNearUser.isHidden = false
            self.btnSeeMoreProfile.isHidden = false
            self.btnSeeMoreProfile.isUserInteractionEnabled = true
            self.stackMoreUser.isHidden = false
        }
        
        for (index, beacon) in arr.enumerated() {
            
            if !arr7PlusList.isEmpty {
                
                self.lblAllNearUser.isHidden = false
                
                switch index {
                        
                    case 0:
                        self.setBubbleImageForMoreUser(beacon: beacon, imageView: self.imgMoreUser1)
                        self.lblAllNearUser.isHidden = false
                        self.viewMoreUser1.isHidden = false
                        self.viewMoreUser2.isHidden = true
                        self.viewMoreUser3.isHidden = true
                        self.viewMoreUser4.isHidden = true
                        
                    case 1:
                        self.setBubbleImageForMoreUser(beacon: beacon, imageView: self.imgMoreUser2)
                        self.lblAllNearUser.isHidden = false
                        self.viewMoreUser1.isHidden = false
                        self.viewMoreUser2.isHidden = false
                        self.viewMoreUser3.isHidden = true
                        self.viewMoreUser4.isHidden = true
                        
                    case 2:
                        self.setBubbleImageForMoreUser(beacon: beacon, imageView: self.imgMoreUser3)
                        self.lblAllNearUser.isHidden = false
                        self.viewMoreUser1.isHidden = false
                        self.viewMoreUser2.isHidden = false
                        self.viewMoreUser3.isHidden = false
                        self.viewMoreUser4.isHidden = true
                        
                    case 3:
                        self.viewMoreUser4.isHidden = false
                        self.lblAllNearUser.isHidden = false
                        self.lblMoreUserCount.text = "+0"
                        
                    default:
                        self.lblAllNearUser.isHidden = false
                        break
                }
            }
            
            if arr.count > 3 {
                count = arr.count - 3
                self.viewMoreUser4.isHidden = false
                self.lblMoreUserCount.text = "+\(count)"
            }
        }
    }
    
    //    @objc func moveCenterView(gesture: UIPanGestureRecognizer) {
    //
    //        let translation = gesture.translation(in: self.view)
    //
    //        let newX = gesture.view!.center.x + translation.x
    //        let newY = gesture.view!.center.y + translation.y
    //        let senderWidth = gesture.view!.bounds.width / 2
    //        let senderHight = gesture.view!.bounds.height / 2
    //
    //        if newX <= senderWidth {
    //            gesture.view!.center = CGPoint(x: senderWidth, y: gesture.view!.center.y + translation.y)
    //
    //        } else if newX >= self.view.bounds.maxX - senderWidth {
    //            gesture.view!.center = CGPoint(x: self.view.bounds.maxX - senderWidth, y: gesture.view!.center.y + translation.y)
    //
    //        } else if newX >= self.viewCircleBoundary.bounds.maxX - senderWidth {
    //            gesture.view!.center = CGPoint(x: self.viewCircleBoundary.bounds.maxX - senderWidth, y: gesture.view!.center.y + translation.y)
    //        }
    //
    //        if newY <= senderHight {
    //            gesture.view!.center = CGPoint(x: gesture.view!.center.x + translation.x, y: senderHight)
    //
    //        } else if newY >= self.viewCircleBoundary.bounds.maxY - senderHight {
    //            gesture.view!.center = CGPoint(x: gesture.view!.center.x + translation.x, y: self.viewCircleBoundary.bounds.maxY - senderHight)
    //
    //        } else if newY >= self.view.bounds.maxY - senderHight {
    //            gesture.view!.center = CGPoint(x: gesture.view!.center.x + translation.x, y: self.view.bounds.maxY - senderHight)
    //
    //        } else {
    //            gesture.view!.center = CGPoint(x: gesture.view!.center.x + translation.x, y: gesture.view!.center.y + translation.y)
    //        }
    //        gesture.setTranslation(CGPointZero, in: self.view)
    //    }
    
    @objc func onBtnNearByBubble(sender: UIButton) {
        
        guard let bubbleView = sender.superview else {
            return
        }
        
        guard let imgBeacon = bubbleView.subviews.compactMap({ $0 as? UIImageView }).first,
              let lblBeacon = bubbleView.subviews.compactMap({ $0 as? UILabel }).first,
              let imgIncompleteProfile = bubbleView.subviews.compactMap({ $0 as? UIImageView }).first
        else {
            return
        }
        
        // Find the bubble corresponding to the tapped button
        let bubble = self.arrBubble.filter { (bub) -> Bool in
            return bub.tag == sender.tag
        }[0]
        
        // Find the beacon associated with the bubble
        let beacon = self.arrBeacon.filter { (bec) -> Bool in
            return bec.uuid == bubble.uuid && bec.major == bubble.major && bec.minor == bubble.minor
        }[0]
        
        // Find nearby data based on beacon uuid
        let nearbyData = self.arrBeacon.filter { (nearbyBeacon) -> Bool in
            return beacon.uuid == nearbyBeacon.userDetail?.id
        }
        
        if nearbyData.count == 1 {
            
            if beacon.userDetail?.user_mode == "1" && beacon.userDetail?.subscriptionStatus == "1" {
                
                if loginUser?.business_username == "" || loginUser?.business_username == nil || loginUser?.business_profileURL == "" || loginUser?.business_profileURL == nil {
                    
                    //FinishProfileVC | Red Icon
                    //print("Profile is Incomplete")
                    self.imgIncompleteProfile.isHidden = false
                    
                    // Present FinishProfileVC for users with incomplete profiles
                    let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
                    finishProfileVC.modalTransitionStyle = .crossDissolve
                    finishProfileVC.modalPresentationStyle = .overCurrentContext
                    self.present(finishProfileVC, animated: true)
                    
                } else if beacon.userDetail?.business_username == nil || beacon.userDetail?.business_username == "" || beacon.userDetail?.business_profileURL == "" || beacon.userDetail?.business_profileURL == nil {
                    
                    let nearbyUserIncompleteProfileVC = NearbyUserIncompleteProfileVC.instantiate(fromAppStoryboard: .Login)
                    nearbyUserIncompleteProfileVC.nearByUserId = nearbyData[0].userDetail?.id ?? ""
                    nearbyUserIncompleteProfileVC.onDismiss = { userDetail in
                        
                        if userDetail.business_username == nil || userDetail.business_username == "" || userDetail.business_profileURL == "" || userDetail.business_profileURL == nil {
                            imgIncompleteProfile.isHidden = false
                        } else {
                            imgIncompleteProfile.isHidden = true
                        }
                        
                        DispatchQueue.main.async {
                            if userDetail.user_mode == "1" && userDetail.subscriptionStatus == "1" {
                                
                                if let profileURL = URL(string: userDetail.business_profileURL ?? "") {
                                    
                                    imgBeacon.af_setImage(withURL: profileURL)
                                    
                                } else {
                                    
                                    // Use initials if profile image URL is not available
                                    imgBeacon.image = UIImage.imageWithInitial(initial: "\(userDetail.business_firstName?.capitalized.first ?? "A")\(userDetail.business_lastName?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                                }
                                lblBeacon.text = userDetail.business_firstName ?? ""
                                
                            } else {
                                
                                if let profileURL = URL(string: userDetail.profile_img ?? "") {
                                    
                                    imgBeacon.af_setImage(withURL: profileURL)
                                    
                                } else {
                                    
                                    // Use initials if profile image URL is not available
                                    imgBeacon.image = UIImage.imageWithInitial(initial: "\(userDetail.firstname?.capitalized.first ?? "A")\(userDetail.lastname?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                                }
                                lblBeacon.text = "\(userDetail.firstname ?? "") \(userDetail.lastname ?? "")"
                            }
                        }
                    }
                    nearbyUserIncompleteProfileVC.modalTransitionStyle = .crossDissolve
                    nearbyUserIncompleteProfileVC.modalPresentationStyle = .overCurrentContext
                    self.present(nearbyUserIncompleteProfileVC, animated: true)
                    
                } else {
                    
                    //print("Profile is Completed")
                    self.imgIncompleteProfile.isHidden = true
                    
                    self.nearByUserDetail = nearbyData[0].userDetail ?? UserDetail()
                    
                    // Present ProfileVC for users with completed profiles
                    let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                    profileVC.navigationScreen = .discover
                    profileVC.nearByUserId = nearbyData[0].userDetail?.id ?? ""
                    profileVC.user_mode = nearbyData[0].userDetail?.user_mode
                    profileVC.subscriptionStatus = nearbyData[0].userDetail?.subscriptionStatus
                    
                    // Update current user details in the profileVC
                    profileVC.getCurrentUserUpdate { userDetail in
                        
                        if let index = self.arrBeacon.firstIndex(where: { $0.userDetail?.id == userDetail.id }) {
                            self.arrBeacon[index].userDetail = userDetail
                            
                            if userDetail.user_mode == "1" && userDetail.subscriptionStatus == "1" {
                                
                                if let profileURL = URL(string: userDetail.business_profileURL ?? "") {
                                    imgBeacon.af_setImage(withURL: profileURL)
                                    
                                } else {
                                    
                                    // Use initials if profile image URL is not available
                                    imgBeacon.image = UIImage.imageWithInitial(initial: "\(userDetail.business_firstName?.capitalized.first ?? "A")\(userDetail.business_lastName?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                                }
                                lblBeacon.text = userDetail.business_firstName ?? ""
                                
                            } else {
                                
                                if let profileURL = URL(string: userDetail.profile_img ?? "") {
                                    imgBeacon.af_setImage(withURL: profileURL)
                                    
                                } else {
                                    
                                    // Use initials if profile image URL is not available
                                    imgBeacon.image = UIImage.imageWithInitial(initial: "\(userDetail.firstname?.capitalized.first ?? "A")\(userDetail.lastname?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                                }
                                lblBeacon.text = "\(userDetail.firstname ?? "") \(userDetail.lastname ?? "")"
                            }
                        }
                    }
                    
                    // Use a custom transition for navigation
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromTop
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    
                    self.navigationController?.pushViewController(profileVC, animated: false)
                }
                
            } else {
                
                if loginUser?.username == "" || loginUser?.username == nil || loginUser?.profile_img == "" || loginUser?.profile_img == nil {
                    
                    //FinishProfileVC | Red Icon
                    //print("Profile is Incomplete")
                    self.imgIncompleteProfile.isHidden = false
                    
                    // Present FinishProfileVC for users with incomplete profiles
                    let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
                    finishProfileVC.modalTransitionStyle = .crossDissolve
                    finishProfileVC.modalPresentationStyle = .overCurrentContext
                    self.present(finishProfileVC, animated: true)
                    
                } else if beacon.userDetail?.username == nil || beacon.userDetail?.username == "" || beacon.userDetail?.profile_img == "" || beacon.userDetail?.profile_img == nil {
                    
                    let nearbyUserIncompleteProfileVC = NearbyUserIncompleteProfileVC.instantiate(fromAppStoryboard: .Login)
                    nearbyUserIncompleteProfileVC.nearByUserId = nearbyData[0].userDetail?.id ?? ""
                    nearbyUserIncompleteProfileVC.onDismiss = { userDetail in
                        
                        if userDetail.username == nil || userDetail.username == "" || userDetail.profile_img == "" || userDetail.profile_img == nil {
                            imgIncompleteProfile.isHidden = false
                            
                        } else {
                            imgIncompleteProfile.isHidden = true
                        }
                        
                        DispatchQueue.main.async {
                            if userDetail.user_mode == "1" && userDetail.subscriptionStatus == "1" {
                                
                                if let profileURL = URL(string: userDetail.business_profileURL ?? "") {
                                    
                                    imgBeacon.af_setImage(withURL: profileURL)
                                    
                                } else {
                                    
                                    // Use initials if profile image URL is not available
                                    imgBeacon.image = UIImage.imageWithInitial(initial: "\(userDetail.business_firstName?.capitalized.first ?? "A")\(userDetail.business_lastName?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                                }
                                lblBeacon.text = userDetail.business_firstName ?? ""
                                
                            } else {
                                
                                if let profileURL = URL(string: userDetail.profile_img ?? "") {
                                    
                                    imgBeacon.af_setImage(withURL: profileURL)
                                    
                                } else {
                                    
                                    // Use initials if profile image URL is not available
                                    imgBeacon.image = UIImage.imageWithInitial(initial: "\(userDetail.firstname?.capitalized.first ?? "A")\(userDetail.lastname?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                                }
                                lblBeacon.text = "\(userDetail.firstname ?? "") \(userDetail.lastname ?? "")"
                            }
                        }
                    }
                    nearbyUserIncompleteProfileVC.modalTransitionStyle = .crossDissolve
                    nearbyUserIncompleteProfileVC.modalPresentationStyle = .overCurrentContext
                    self.present(nearbyUserIncompleteProfileVC, animated: true)
                    
                } else {
                    
                    //print("Profile is Completed")
                    self.imgIncompleteProfile.isHidden = true
                    self.nearByUserDetail = nearbyData[0].userDetail ?? UserDetail()
                    
                    // Present ProfileVC for users with completed profiles
                    let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                    profileVC.navigationScreen = .discover
                    profileVC.nearByUserId = nearbyData[0].userDetail?.id ?? ""
                    profileVC.user_mode = nearbyData[0].userDetail?.user_mode
                    profileVC.subscriptionStatus = nearbyData[0].userDetail?.subscriptionStatus
                    
                    // Update current user details in the profileVC
                    profileVC.getCurrentUserUpdate { userDetail in
                        
                        if let index = self.arrBeacon.firstIndex(where: { $0.userDetail?.id == userDetail.id }) {
                            self.arrBeacon[index].userDetail = userDetail
                            
                            if userDetail.user_mode == "1" && userDetail.subscriptionStatus == "1" {
                                
                                if let profileURL = URL(string: userDetail.business_profileURL ?? "") {
                                    imgBeacon.af_setImage(withURL: profileURL)
                                    
                                } else {
                                    
                                    // Use initials if profile image URL is not available
                                    imgBeacon.image = UIImage.imageWithInitial(initial: "\(userDetail.business_firstName?.capitalized.first ?? "A")\(userDetail.business_lastName?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                                }
                                lblBeacon.text = userDetail.business_firstName ?? ""
                                
                            } else {
                                
                                if let profileURL = URL(string: userDetail.profile_img ?? "") {
                                    imgBeacon.af_setImage(withURL: profileURL)
                                    
                                } else {
                                    
                                    // Use initials if profile image URL is not available
                                    imgBeacon.image = UIImage.imageWithInitial(initial: "\(userDetail.firstname?.capitalized.first ?? "A")\(userDetail.lastname?.capitalized.first ?? "B")", imageSize: imgBeacon.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                                }
                                lblBeacon.text = "\(userDetail.firstname ?? "") \(userDetail.lastname ?? "")"
                            }
                        }
                    }
                    
                    // Use a custom transition for navigation
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromTop
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    
                    self.navigationController?.pushViewController(profileVC, animated: false)
                }
            }
        }
    }
    
    func getTaptoosocialData(payloadData: NotificationPayloadData, indx: Int) {
        
        if payloadData.sender_id! == self.arrBeacon[indx].uuid && payloadData.receiver_id! == UserLocalData.UserID {
            
            let name = payloadData.sender_name ?? ""
            self.arrBeacon[indx].isTapSocial = true
            self.arrBeacon[indx].descriptionField = String(format: "%@, wants to be social.👋", name)
            //beaconManager.generateNotification(beacon: self.arrBeacon[indx])
            BLEManager.shared.generateNotification(beacon: self.arrBeacon[indx])
        }
    }
    
    func shareUserProfileURLWithMetadata(metaData: LPLinkMetadata) {
        let metadataItemSource = LinkPresentationItemSource(metaData: metaData)
        let activity = UIActivityViewController(activityItems: [metadataItemSource], applicationActivities: [])
        present(activity, animated: true)
    }
}

// --------------------------------------------------------------------------
//                       MARK: - BLEManagerDelegate -
// --------------------------------------------------------------------------
extension DiscoverVC: BLEManagerDelegate {
    
    func deviceWentOutOfRange(_ device: BLEDevice) {
        
        print("**********************************************************")
        print("Device ID to remove :: ", device.uuid ?? "")
        print("arrBeacon count:", self.arrBeacon.count)
        for element in self.arrBeacon {
            print("arrBeacon peripheralUUID ::", element.peripheralUUID ?? "")
        }
        
        if let index = self.arrBeacon.firstIndex(where: { $0.peripheralUUID == device.uuid }) {
            print("Index of peripheral UUID \(String(describing: device.uuid)) in arrBeacon: \(index)")
            
            DispatchQueue.main.async {
                self.removeBubbleAtIndex(index: index)
            }
            self.arrBeacon.remove(at: index)
            
            // Check if the beacon exists in arr7BubbleInView and remove it
            if let bubbleIndex = self.arr7BubbleInView.firstIndex(where: { $0.peripheralUUID == device.uuid }) {
                self.arr7BubbleInView.remove(at: bubbleIndex)
                if let removedBubble = arr7PlusList.first {
                    self.arr7PlusList.removeFirst()
                    self.arr7BubbleInView.append(removedBubble)
                }
            }
            
            // Check if the beacon exists in arr7PlusList and remove it
            if let plusListIndex = arr7PlusList.firstIndex(where: { $0.peripheralUUID == device.uuid }) {
                self.arr7PlusList.remove(at: plusListIndex)
            }
            
            DispatchQueue.main.async {
                self.setAllBubbles()
                self.updateSeeMoreUserView(arr: self.arr7PlusList)
            }
            
        } else {
            print("Peripheral UUID \(String(describing: device.uuid)) not found in arrBeacon")
        }
        
        if self.arr7BubbleInView.count <= 7, let index = self.arr7BubbleInView.firstIndex(where: { $0.peripheralUUID == device.uuid }) {
            self.arr7BubbleInView.remove(at: index)
            print("Beacon reemoved from arr7BubbleInView")
        }
        
        print("-----------------------------------------------")
        // Remove from arr7PlusList if count > 0
        if !self.arr7PlusList.isEmpty, let index = self.arr7PlusList.firstIndex(where: { $0.peripheralUUID == device.uuid }) {
            self.arr7PlusList.remove(at: index)
            print("Beacon reemoved from arr7PlusList")
        }
        print("-----------------------------------------------")
        print("arrBeacon", self.arrBeacon.count)
        print("arr7PlusList", self.arr7PlusList.count)
        print("arr7BubbleInView", self.arr7BubbleInView.count)
        print("arrBubble", self.arrBubble.count)
    }
    
    private func removeBubbleAtIndex(index: Int) {
        guard index >= 0 && index < self.arrBubble.count else {
            print("Invalid index")
            return
        }
        
        let removedBubble = self.arrBubble.remove(at: index)
        let bubbleTag = removedBubble.tag
        
        // Remove the corresponding view from viewCircleBoundary
        if let bubbleView = self.viewCircleBoundary.viewWithTag(bubbleTag) {
            bubbleView.removeFromSuperview()
            print("Bubble removed from View")
        } else {
            print("Bubble view not found for tag \(bubbleTag)")
        }
        
        // Remove the user with the corresponding peripheral UUID from degreeListDictionary
    }
}

// --------------------------------------------------------------------------
//                       MARK: - UIViewControllerTransitioningDelegate -
// --------------------------------------------------------------------------
extension DiscoverVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactor.hasStarted ? self.interactor : nil
    }
}

// --------------------------------------------------------------------
//                       MARK: - UIGestureRecognizerDelegate -
// --------------------------------------------------------------------
extension DiscoverVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension DiscoverVC: DiscoverCaptionDelegate {
    
    func setCaptionInDiscover(caption: String) {
        
        if let existingCaptionView = self.viewCaption {
            existingCaptionView.removeFromSuperview() // Remove the existing caption view
        }
        
        if self.btnBLEOnOff.isSelected == true {
            
            // Add new caption view if caption is not empty
            self.viewProfile.sizeToFit()
            self.viewCaption = self.setCaptionView(labelText: caption, frame: self.viewProfile.frame)
            self.viewMain.addSubview(self.viewCaption ?? UIView())
        }
    }
}

class RepeatingTimer {
    
    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    var eventHandler: (() -> Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    
    private var state: State = .suspended
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        resume()
        eventHandler = nil
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}

class LinkPresentationItemSource: NSObject, UIActivityItemSource {
    var linkMetaData = LPLinkMetadata()
    
    //Prepare data to share
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return linkMetaData
    }
    
    //Placeholder for real data, we don't care in this example so just return a simple string
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    /// Return the data will be shared
    /// - Parameters:
    ///   - activityType: Ex: mail, message, airdrop, etc..
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return linkMetaData.originalURL
    }
    
    init(metaData: LPLinkMetadata) {
        self.linkMetaData = metaData
    }
}
