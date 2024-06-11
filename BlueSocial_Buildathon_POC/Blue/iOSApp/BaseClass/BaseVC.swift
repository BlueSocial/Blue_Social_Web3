//
//  BaseVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import CoreLocation
import FirebaseDynamicLinks
import WidgetKit
import Toast_Swift

class BaseVC: UIViewController {
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    static let sharedInstance = BaseVC()
    let dateFormatter = DateFormatter()
    let initialsLabel = UILabel()
    private var loadingView: CustomLoadingView?
    
    // ----------------------------------------------------------
    //                       MARK: - CustomLoadingView -
    // ----------------------------------------------------------
    func showCustomLoader() {
        self.loadingView = CustomLoadingView(gifName: customLoaderGIF)
        if let loadingView = self.loadingView {
            self.view.addSubview(loadingView)
        }
    }
    
    func hideCustomLoader() {
        self.loadingView?.stopAnimating()
        self.loadingView?.removeFromSuperview()
        self.loadingView = nil
    }
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override var childForStatusBarStyle: UIViewController? {
        self.children.first
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    // To add nearByUser in Interactions List
    public func callDeviceScanAPI(scanType: String, NFCURL: String, receiverID: String, lat: Double, lng: Double) {
        self.view.endEditing(true)
        
        let url = BaseURL + APIName.kDeviceScan
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kDeviceScan,
                                    APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kReceiverId: receiverID,
                                    APIParamKey.kDeviceScanType: scanType,
                                    APIParamKey.kNFC_URL: NFCURL,
                                    APIParamKey.kLat: lat,
                                    APIParamKey.kLng: lng]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                print("Function: \(#function), line: \(#line) MSG: \(msg)")
            } else {
                //self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    func callBreakTheIceRequestAPI(param: [String: Any], completion: @escaping (_ isSuccess: Bool, _ message: String?) -> Void) {
        
        let url = BaseURL + APIName.kBreakTheIceRequest
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                completion(true, msg)
            } else {
                completion(false, msg)
            }
            //self.view.makeToast(msg)
        }
    }
    
    func callNotifyConnectUserAPI(param: [String: Any], completion: @escaping (_ isSuccess: Bool, _ message: String?) -> Void) {
        
        let url = BaseURL + APIName.kNotifyConnectUser
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                completion(true, msg)
            } else {
                completion(false, msg)
            }
            //self.view.makeToast(msg)
        }
    }
    
    func setQRCodeURLForWidget() {
        
        // Create the UserDefaults suites for Widget
        let appWidgetSuite = UserDefaults(suiteName: "group.social.blue.app.Blue-Widget")
        
        // Set values in suites
        if let unique_url = loginUser?.unique_url {
            appWidgetSuite?.set(unique_url + "?type=QR", forKey: "BlueUserWidgetQRCode")
        } else {
            appWidgetSuite?.set("https://blue.social/", forKey: "BlueUserWidgetQRCode")
        }
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func getLocalTimeFromUTC(timestamp: String) -> String {
        
        let dateFormatUTC = DateFormatter()
        dateFormatUTC.locale = Locale(identifier: "en_US_POSIX")
        dateFormatUTC.dateFormat = "yyyy-MM-dd"
        dateFormatUTC.timeZone = TimeZone(identifier: "UTC")
        
        guard let dateTimeUTC = dateFormatUTC.date(from: timestamp) else {
            return "Invalid Timestamp: \(timestamp)"
        }
        
        // Convert UTC time to local time
        let dateFormatLocal = DateFormatter()
        dateFormatLocal.dateFormat = "yyyy-MM-dd"
        dateFormatLocal.timeZone = TimeZone.current
        
        let dateTimeLocal = dateFormatLocal.string(from: dateTimeUTC)
        print("Converted UTC to local:", dateTimeLocal)
        return dateTimeLocal
    }
    
    func getCurrentUTCTimestamp() -> String {
        
        // Get the current date and time
        let currentDate = Date()
        
        // Create a DateFormatter instance
        let dateFormatter = DateFormatter()
        
        // Set the date format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Set the timezone to UTC
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Convert the date to a string
        let utcString = dateFormatter.string(from: currentDate)
        
        // Return the UTC string
        return utcString
    }
    
    // callGetUserInfoAPI to get only required details of nearByUser to create bubble on Discover screen
    public func callGetUserInfoAPI(nearByUserID: String, completion: @escaping (_ isSuccess: Bool, _ response: UserDetail?) -> Void) {
        
        let url = BaseURL + APIName.kGetUserInfo
        
        let param: [String: Any] = [APIParamKey.kId: nearByUserID]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                
                guard let objGetInfo = response?.userDetail else { return }
                
                completion(true, objGetInfo)
                
            } else {
                
                completion(false, nil)
            }
        }
    }
    
    public func callGetInfoAPI(needToShowAlertForFailure: Bool = false, isFromLoginRegister: Bool = false, UserID: String = "", isFromQRCode: Bool = false, slug: String = "", completion: @escaping (_ isSuccess: Bool, _ response: UserDetail?) -> Void) {
        
        let url = BaseURL + APIName.kGetInfo
        
        var param: [String: Any] = [:]
        
        if isFromLoginRegister {
            param = [
                APIParamKey.kFlag: APIFlagValue.kGetProfile,
                APIParamKey.kId: UserID,
                APIParamKey.kAppVersion: self.getAppVersion(),
                APIParamKey.kDeviceType: APIFlagValue.kiPhone
            ]
        } else if isFromQRCode {
            param = [
                APIParamKey.kFlag: APIFlagValue.kGetProfile,
                APIParamKey.kId: "",
                APIParamKey.kType: APIFlagValue.kSlug,
                APIParamKey.kSlug: slug
            ]
        } else {
            param = [
                APIParamKey.kFlag: APIFlagValue.kGetProfile,
                APIParamKey.kId: UserID
            ]
        }
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                guard let objGetInfo = response?.userDetail else { return }
                
                if UserID == UserLocalData.UserID {
                    
                    loginUser = objGetInfo
                    loginUser?.social_network = response?.userDetail?.social_network
                    UserLocalData.referalInviteUrl = objGetInfo.referral_invite_url ?? ""
                    UserLocalData.isEmailVerify = objGetInfo.is_email_verify ?? "0" // "0" - Not Verified | "1" - Verified | "2" - Pending
                    
                    if loginUser != nil {
                        
                        if loginUser?.subscriptionStatus == "0" {
                            
                            // set user mode to 0
                            UserLocalData.userMode = "0"
                            loginUser?.user_mode = "0"
                        }
                    }
                    
                    self.setQRCodeURLForWidget()
                }
                
                if !isFromQRCode {
                    self.setUserSocialInfoInDB(userID: UserID, userJSON: objGetInfo.toJSONString()!)
                }
                
                completion(true, objGetInfo)
                
            } else {
                
                completion(false, nil)
                
                if needToShowAlertForFailure {
                    self.showAlertWithOKButton(message: msg) // The request timed out. | JSON Seri. | cannot parse response
                }
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func checkPasswordValidity(password: String) -> String? {
        
        let passwordRegex = "^(?=.*[!@#$%^&*()_+{}\\[\\]:;<>,.?~\\-]).*(?=.*[A-Z]).*(?=.*[a-z]).*(?=.*\\d).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        if !passwordTest.evaluate(with: password) {
            
            // Check all validation simultaneously
            return "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one digit, and one special character"
        }
        
        return nil
    }
    
    //To get detail all account i.e Details of multiple users
    func getMultipleUserAccount() {
        
        arrAccount = UserLocalData.arrOfAccountData
    }
    
    func getAppVersionAndBuildNumber() -> String {
        
        let buildNumber = Bundle.main.infoDictionary?[getCFBundleVersion]
        if let appVersion = Bundle.main.infoDictionary?[getCFBundleShortVersionString] {
            return "v.\(appVersion)-\(buildNumber ?? "")"
        }
        return "1.0"
    }
    
    func getAppVersion() -> String {
        
        if let appVersion = Bundle.main.infoDictionary?[getCFBundleShortVersionString] {
            return "\(appVersion)"
        }
        return "1.0"
    }
    
    //Used to generate local notification
    public func generateLocalNotification(payloadData: NotificationPayloadData) {
        
        let content = UNMutableNotificationContent()
        
        switch payloadData.notify {
            case NotificationType.TapToBeN.type():
                content.title = "New Interaction" //"Near by User"
                break
            case NotificationType.Accepted.type():
                content.title = "Near by User"
                break
            case NotificationType.Decline.type():
                content.title = "Near by User"
                break
            default:
                break
        }
        
        content.body     = (payloadData.sender_name ?? "") + " " +  (payloadData.message ?? "")
        content.userInfo = payloadData.toJSON()
        content.badge    = 0
        content.sound    = .default
        
        let request = UNNotificationRequest(identifier: "beacon.beaconid!", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
        })
    }
    
    //For Setting attributed string
    func setAttributedText(username: String, color: UIColor, link: String = "https://www.profiles.blue/") -> NSAttributedString {
        
        let firstAttributes = [NSAttributedString.Key.foregroundColor: color]
        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
        
        let firstString = NSMutableAttributedString(string: link, attributes: firstAttributes)
        let secondString = NSAttributedString(string: username , attributes: secondAttributes as [NSAttributedString.Key : Any])
        
        firstString.append(secondString)
        return firstString
    }
    
    func setUserSocialInfoInDB(userID: String, userJSON: String) {
        
        let dbUserData = DBManager.checkUserSocialInfoExist(userID: userID)
        
        if dbUserData.isSuccess {
            
            let isSocialProfileUpdated = DBManager.updateSocialProfile(userID: userID, requestBody: userJSON)
            print("isSocialProfileUpdated :: \(isSocialProfileUpdated)")
            
        } else {
            
            let isUserDataInsterted = DBManager.insertUserData(userID: userID, requestBody: userJSON, businessProfile: "")
            print("isUserDataInsterted :: \(isUserDataInsterted)")
        }
    }
    
    func getLoginUserDataFromDB(userMode: String, completion: @escaping (_ isSuccess: Bool , _ response: UserDetail?) -> Void) {
        
        switch userMode {
                
            case "0":
                let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
                
                if dbUserData.isSuccess && dbUserData.userData != nil {
                    loginUser = dbUserData.userData
                    completion(true, loginUser)
                } else {
                    self.showCustomLoader()
                    self.callGetInfoAPI(needToShowAlertForFailure: false, UserID: UserLocalData.UserID) { (isSuccess, response) in
                        
                        if isSuccess {
                            loginUser = response
                        }
                        completion(isSuccess, response)
                    }
                }
                
                self.callGetInfoAPI(UserID: UserLocalData.UserID) { (isSuccess, response) in
                    
                    if isSuccess {
                        loginUser = response
                    }
                    completion(isSuccess, response)
                }
                break
                
            default:
                break
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - user Logout -
    // ----------------------------------------------------------
    func checkAndRemoveCurrentUserData(userID: String) -> Bool {
        
        if DBManager.isMultipleAccountExist(userID: userID)! {
            let _ = DBManager.removeCurrentFromMultipleAccount(userID: userID)
        }
        
        if DBManager.checkUserSocialInfoExist(userID: userID).isSuccess {
            let _ = DBManager.removeCurrentUserData(userID: userID)
        }
        
        if DBManager.isDeviceHistoryExist(userID: userID) {
            let _ = DBManager.removeCurrentDeviceHistory(userID: userID)
        }
        
        if DBManager.isproductDataListExist(userID: userID) {
            let _ = DBManager.removeCurrentproductDataList(userID: userID)
        }
        
        if DBManager.isDeviceEventDataExist(userID: userID) {
            let _ = DBManager.removeCurrentEventData(userID: userID)
        }
        
        return true
    }
    
    //To display alert with 1 button
    func DAlertWithButton(buttonText: String, message: String, _ completion: (() -> ())? = nil) {
        
        let alert = UIAlertController(title: kAppName, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: buttonText, style: .cancel) { (ok) in
            completion?()
        }
        
        alert.addAction(okAction)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func notifyToBrodcastMyProfile() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            NotificationCenter.default.post(name: .nearByOn, object: UserLocalData.isNetworkmode, userInfo: nil)
        }
    }
    
    func setRootViewController() {
        
        var rootVC: UIViewController
        
        if UserLocalData.UserID != "" {
            
            if UserLocalData.ShouldShowTourScreen == false {
                
                let tourPageMasterVC = TourPageMasterViewController.instantiate(fromAppStoryboard: .Tour)
                self.navigationController?.pushViewController(tourPageMasterVC, animated: true)
                
            } else {
                
                let tabbar = MainTabbarController.instantiate(fromAppStoryboard: .Discover)
                tabbar.selectedIndex = 1 // Select the desired tab index
                
                // Set the tab bar controller as the root view controller
                rootVC = tabbar
                let navigationController = UINavigationController(rootViewController: rootVC)
                navigationController.setNavigationBarHidden(true, animated: true)
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if let window = appDelegate.window {
                        // Now you have access to the window instance.
                        window.rootViewController = navigationController
                        window.makeKeyAndVisible()
                    }
                }
            }
            
        } else {
            
            let chooseRoleVC = ChooseRoleVC.instantiate(fromAppStoryboard: .Login)
            self.navigationController?.pushViewController(chooseRoleVC, animated: false)
        }
    }
    
    func returnTwoDigitAfterDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    func returnTwoDigitAfterDecimal(_ value: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    func getWidthFromSting(value: String, fromFont: UIFont) -> CGFloat {
        let lblDescription = UILabel()
        lblDescription.numberOfLines = 1
        lblDescription.text = value
        lblDescription.font = fromFont
        lblDescription.sizeToFit()
        return lblDescription.frame.width
    }
}
