//
//  AppDelegate.swift
//  Blue
//
//  Created by Blue.

import UIKit
import IQKeyboardManagerSwift
import ObjectMapper
import GooglePlaces
import GoogleMaps
import OneSignalFramework
import AlamofireImage
import UserNotifications
import Firebase
import FirebaseCrashlytics
import FirebaseMessaging
import FirebaseInstallations
import FirebaseAnalytics
import FirebaseCore
import FirebaseDynamicLinks
import FirebaseAuth
import Instabug

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var notificationDelegate: PushNotificationDelegate?
    var notificationReceivedDelegate: ReceivedPushNotificationDelegate?
    
    // @ethan
    func setupReactNative() {
      let jsCodeLocation: URL
      jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackExtension: nil)!

      let bridge = RCTBridge(bundleURL: jsCodeLocation, moduleProvider: nil, launchOptions: nil)
      let rootView = RCTRootView(bridge: bridge!, moduleName: "MyReactNativeApp", initialProperties: nil)

      self.window = UIWindow(frame: UIScreen.main.bounds)
      let rootViewController = UIViewController()
      rootViewController.view = rootView
      self.window?.rootViewController = rootViewController
      self.window?.makeKeyAndVisible()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Application Life Cycle -
    // ----------------------------------------------------------
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupReactNative()
        
        BaseVC.sharedInstance.setQRCodeURLForWidget()
        UserLocalData.isbtnBLEOn = true
        
        // MARK: - Internet Rechability -
        self.setInternetRechability()
        
        // MARK: - SQLite -
        _ = SQLiteDB.shared.openDB(copyFile: true)
        
        // MARK: - getLoginUserDataFromDB -
        if UserLocalData.UserID != "" {
            
            BaseVC.sharedInstance.getLoginUserDataFromDB(userMode: UserLocalData.userMode) { isSuccess, userData in
                if isSuccess {}
            }
        }
        
        // MARK: - Database Migration -
        self.manageDBVersion()
        
        BaseVC.sharedInstance.getMultipleUserAccount()
        
        ///Used to reset or clear the badge number on the app icon in iOS.
        ///The badge number is the numerical indicator displayed on the app icon to inform the user about pending notifications or messages.
        ///Setting applicationIconBadgeNumber to 0 instructs iOS to remove the badge from the app icon, indicating that there are no pending notifications.
        ///This is commonly done when the user opens the app and views the notifications, signifying that they have been acknowledged.
        ///It's important to note that directly modifying the badge number is a client-side operation and doesn't affect the server or the actual state of notifications.
        ///If your app communicates with a server for push notifications, the server needs to be informed separately when the notifications are read or acknowledged.
        ///Typically, you might use this line of code in response to a user action, such as opening the app or navigating to a particular screen where you want to clear the badge.
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // MARK: - Google Places & Maps API -
        ///To use the Google Places API, you need to obtain an API key from the Google Cloud Console and replace the string.
        GMSPlacesClient.provideAPIKey("AIzaSyDDKRxHf1HU-8BA8_dC4pQtBEYLf-yYt7Y")
        
        ///To use the Google Maps SDK for iOS, you need to obtain an API key from the Google Cloud Console and replace the string
        GMSServices.provideAPIKey("AIzaSyB_06DZujhA88AJhli5ScXEuGDhnR_OeW0")
        
        // MARK: - Firebase -
        ///Replace "your-deep-link-scheme" with your actual URL scheme. The URL scheme is used to open your app when a user clicks on a Dynamic Link.
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "social.blue.app"
        
        ///To set up Firebase services. Make sure you have the Firebase SDK integrated into your project and that you've added the necessary configuration files.
        ///This method initializes Firebase services, allowing you to use various Firebase features, such as Realtime Database, Cloud Firestore, Authentication, Cloud Functions, Cloud Messaging (FCM), and more.
        FirebaseApp.configure()
        
        ///Enable Firebase Analytics data collection. You are enabling analytics data collection, allowing Firebase Analytics to track user interactions and events within your app.
        ///This method specifically enables or disables analytics data collection for the current app instance.
        ///When you call this method with true, you are explicitly enabling analytics data collection for the app.
        ///It affects the analytics data collection for the current instance of the Firebase Analytics service in your app.
        Analytics.setAnalyticsCollectionEnabled(true)
        
        ///This property controls the default data collection behavior for Firebase services across the entire Firebase app instance.
        ///If you set isDataCollectionDefaultEnabled to true, you are indicating that, by default, data collection is enabled for all Firebase services (including Analytics) within your app.
        ///This affects the default behavior for all Firebase services when they are initialized.
        FirebaseApp.app()?.isDataCollectionDefaultEnabled = true
        
        ///Set the delegate for the Firebase Cloud Messaging (FCM) service.
        ///By setting the delegate to an object that conforms to the MessagingDelegate protocol, you can handle events related to FCM, such as receiving registration tokens and incoming messages.
        Messaging.messaging().delegate = self
        
        ///Enable or Disable automatic initialization of Firebase Cloud Messaging (FCM) in your iOS app. Automatic initialization is a feature that automatically initializes FCM when your app launches. By default, FCM is initialized automatically. However, if you set isAutoInitEnabled to false, you can control when FCM is initialized manually.
        Messaging.messaging().isAutoInitEnabled = true
        
        ///Set the delegate of the UNUserNotificationCenter to an object conforming to the UNUserNotificationCenterDelegate protocol.
        ///To handle notifications in your app.
        UNUserNotificationCenter.current().delegate = self
        
        ///To register the app for remote notifications (push notifications).
        ///To request permission from the user to receive push notifications.
        ///After calling registerForRemoteNotifications(), the app prompts the user to grant or deny permission for receiving push notifications.
        ///If the user grants permission, the app obtains a device token, which can be used by your server to send push notifications to the specific device.
        application.registerForRemoteNotifications()
        
        let acceptAction = UNNotificationAction(identifier: "Accept", title: "Accept", options: [])
        let rejectAction = UNNotificationAction(identifier: "Reject", title: "Reject", options: [])
        let customNotification = UNNotificationCategory(identifier: "9", actions: [acceptAction, rejectAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([customNotification])
        
        // MARK: - IQKeyboardManager -
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .default
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // MARK: - OneSignalNotificationService -
        oneSignalLaunchOption = launchOptions
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
        if self.isRunningLive() {
            Instabug.start(withToken: "68a248ebe60662f5a05c33bd75165a26", invocationEvents: [.none])
        } else {
            Instabug.start(withToken: "7d1cae13e1a76c838f98ceec90722314", invocationEvents: [.none])
        }
        
        return true
    }
    
    func isRunningLive() -> Bool {
#if targetEnvironment(simulator)
        return false
#else
        let isRunningTestFlightBeta = (Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt")
        let hasEmbeddedMobileProvision = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        
        if (isRunningTestFlightBeta || hasEmbeddedMobileProvision) {
            return false
        } else {
            return true
        }
#endif
    }
    
    private func manageDBVersion() {
        
        let dbVersion = DBVersion(rawValue: UserLocalData.UserMigrate)
        
        switch dbVersion {
                
            case .Blank:
                
                // createNewTable: InsightsProfileData
                let isInsightsProfileDataTableCreated = DBManager.createInsightsProfileDataTable()
                print("isInsightsProfileDataTableCreated: \(isInsightsProfileDataTableCreated)")
                
                // ADD COLUMN businessProfile in TABLE UserData
                let isBusinessProfileColumnAddedInUserDataTable = DBManager.modifyUserDataTable()
                print("isBusinessProfileColumnAddedInUserDataTable: \(isBusinessProfileColumnAddedInUserDataTable)")
                
                UserLocalData.UserMigrate = DBVersion.First.rawValue
                
                if UserLocalData.userMode == "" { UserLocalData.userMode = "0" }
                
                if (userDef.value(forKey: APIFlagValue.kLogin) != nil) {
                    UserLocalData.UserID = UserDetail(JSONString: APIFlagValue.kLogin)?.id ?? ""
                    UserLocalData.userMode = UserDetail(JSONString: APIFlagValue.kLogin)?.user_mode ?? "0"
                    UserDefaults.standard.removeObject(forKey: APIFlagValue.kLogin)
                    UserDefaults.standard.synchronize()
                }
                
                fallthrough // Check next case till it gets break statement
                
            case .Zero, .First:
                
                UserLocalData.UserMigrate = DBVersion.Second.rawValue
                fallthrough
                
            case .Second:
                
                let isIndividualProofInteractionTableCreated = DBManager.createIndividualProofInteractionTable()
                print("isIndividualProofInteractionTableCreated: \(isIndividualProofInteractionTableCreated)")
                
                let isNotificationListTableCreated = DBManager.createNotificationListTable()
                print("isNotificationListTableCreated: \(isNotificationListTableCreated)")
                
                UserLocalData.UserMigrate = DBVersion.Third.rawValue
                fallthrough
                
            case .Third:
                break
                
            case .none:
                break
        }
    }
    
    func setUpOneSignalNotification(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        // OneSignal initialization
        OneSignal.initialize(kOnesignalAppID, withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)
        
        // Login your customer with externalId
        OneSignal.login(UserLocalData.UserID)
        
        // You will supply the external id to the OneSignal SDK
        print("loginUser ID: For OneSignal: \(UserLocalData.UserID)")
        // Pass in email provided by customer
        OneSignal.User.addEmail(loginUser?.email ?? "")
        
        // Also check for blank "" because on DiscoverVC there is code: appDelegate.setUpOneSignalNotification(launchOptions: oneSignalLaunchOption) in viewDidLoad, I think it should be write above code after API getInfo called.
        if let userPhone = loginUser?.mobile, loginUser?.mobile != "" {
            
            // Pass in phone number provided by customer
            let components = userPhone.components(separatedBy: "_")
            var phoneNumber = ""
            
            if components.count >= 3 {
                
                if components[1].contains("+") {
                    phoneNumber = components[1] + components[2]
                } else {
                    phoneNumber = ("+" + components[1]) + components[2]
                }
                
            } else if components.count >= 2 {
                
                if components[0].contains("+"){
                    phoneNumber = components[0] + components[1]
                } else {
                    phoneNumber = ("+" + components[0]) + components[1]
                }
            }
            OneSignal.User.addSms(phoneNumber)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        debugPrint("App did Enter Background")
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        debugPrint("App will Enter Foreground")
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        debugPrint("App did beacome Enter Foreground")
        LocationManager.shared.checkLocationAuthorization()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        BLEPeripherals.shared.stopAdvertise()
        BLEManager.shared.stopScanning()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

// ----------------------------------------------------------
//                       MARK: - Internet Rechability -
// ----------------------------------------------------------
extension AppDelegate {
    
    func setInternetRechability() {
        
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
            
        } catch {
            
            switch error as? Network.Error {
                    
                case let .failedToCreateWith(hostname)?:
                    print("Network error:\nFailed to create reachability object With host named:", hostname)
                    
                case let .failedToInitializeWith(address)?:
                    print("Network error:\nFailed to initialize reachability object With address:", address)
                    
                case .failedToSetCallout?:
                    print("Network error:\nFailed to set callout")
                    
                case .failedToSetDispatchQueue?:
                    print("Network error:\nFailed to set DispatchQueue")
                    
                case .none:
                    print(error)
            }
        }
        
        statusManager(Notification(name: Notification.Name(rawValue: "")))
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
    }
    
    @objc func statusManager(_ notification: Notification) {
        
        switch Network.reachability.status {
                
            case .unreachable:
                isInternetAvailable = false
                UIApplication.shared.windows.first?.rootViewController?.showAlertWithOKButton(message: "You need an active data connection to use this application, please check your internet settings and try again.")
                
            case .wwan:
                isInternetAvailable = true
                print(":: Now application connected with celluler network ::")
                
            case .wifi:
                isInternetAvailable = true
                print(":: Now application connected with wifi network ::")
        }
    }
}

// -----------------------------------------------------------------------------
//                       MARK: - MessagingDelegate -
// -----------------------------------------------------------------------------
extension AppDelegate: MessagingDelegate {
    
    ///This method is called when a new registration token is generated or an existing token is refreshed.
    ///It's typically called when the app registers with FCM or when the token is invalidated.
    ///When the FCM token is refreshed or obtained for the first time, the method is triggered.
    ///The FCM token is essential for identifying the device and sending push notifications.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        print("FCM Token = \(fcmToken ?? "")\n")
        pushNotificationToken = fcmToken ?? ""
        
        // You can send this token to your server to associate it with the user
    }
}

// -----------------------------------------------------------------------------
//                       MARK: - UNUserNotificationCenterDelegate -
// -----------------------------------------------------------------------------
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    ///Handle successful registration and obtain the device token
    ///Called when the app successfully registers for remote notifications.
    ///This typically occurs when the app requests permission to receive remote notifications, and the user grants permission.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle registration failure
    }
    
    ///Called when a notification is about to be presented to the user while the app is in the foreground.
    ///This happens when the app is active, and a notification is received.
    ///This delegate method is responsible for determining how the notification should be presented to the user.
    ///The completionHandler parameter is a closure that you need to call with the desired presentation options.
    ///You can specify whether to present the notification with sound, badge, and/or in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Get the associated notification request & Retrieve the identifier from the notification request
        print("willPresent notificationIdentifier :: \(notification.request.identifier)")
        
        if #available(iOS 14.0, *) {
            completionHandler([.badge, .sound, .banner])
        } else {
            completionHandler([.badge, .sound, .alert])
        }
    }
    
    ///Called when the app receives a remote notification (a push notification) while it is running in the foreground or background.
    ///This method is not called if the app is completely terminated.
    ///This method allows you to perform custom handling when a remote notification is received.
    ///The userInfo parameter contains the payload of the notification, and the completionHandler closure is called to let the system know whether the app successfully processed the notification.
    ///It's important to note that if the app is in the foreground, this method is called, and you can handle the notification accordingly.
    ///However, if the app is in the background or terminated, the system may launch the app in the background to handle the notification, and this method is still invoked.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("didReceiveRemoteNotification userInfo :: \(userInfo)")
        
        // it is getting for firebase mobile verification code
        if let authPayload = userInfo["com.google.firebase.auth"] as? [AnyHashable: Any], Auth.auth().canHandleNotification(authPayload) {
            // The notification is intended for Firebase Auth
            completionHandler(.noData)
            return
        }
        
        if userInfo["com.google.firebase.auth"] != nil {
            // it is getting for firebase mobile verification code
            
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
            completionHandler(.noData)
        }
        
        let stringUserInfo = self.stringFrom(dict: userInfo) ?? ""
        
        if let payloadData = NotificationPayloadData(JSONString: stringUserInfo) {
            notificationReceivedDelegate?.notificationReceived(payloadData: payloadData)
        }
    }
    
    ///Called when the user taps on a notification, causing the app to be launched in the background or foreground.
    ///This delegate method is invoked when a user interacts with a notification, such as tapping on it, swiping it, or taking any action defined in the notification's payload.
    ///You can use this method to handle the user's response to the notification and perform appropriate actions.
    ///This method is where you can implement custom logic based on the user's response to a notification.
    ///After handling the response, you should call the completionHandler closure to let the system know that you have finished processing the response.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("didReceive response Notification Clicked userInfo [AnyHashable : Any] :: \(userInfo)")
        
        switch response.actionIdentifier {
                
            case "Accept":
                // Handle action 1
                print("Action 1 clicked")
                
            case "Reject":
                // Handle action 2
                print("Action 2 clicked")
                
            default:
                break
        }
        
        let stringUserInfo = self.stringFrom(dict: userInfo) ?? ""
        print("didReceive response Notification Clicked userInfo in String :: \(stringUserInfo)")
        
        if let payloadData = NotificationPayloadData(JSONString: stringUserInfo) {
            notificationDelegate?.didTapNotification(payloadData: payloadData)
        }
        
        //"view_type" : "13" - inrange
        if userInfo["view_type"] as? String != "13" {
            
            // Enum NotificationType case Notification = "7"
            if let profileType = userInfo["profile_type"] as? String, !UserLocalData.UserID.isEmpty, let receiverID = userInfo["receiver_id"] as? String {
                
                let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                profileVC.isUser_ReferalConnect = profileType == "0" // profileVC.isUser_ReferalConnect = true | false
                // isUser_ReferalConnect == true means that user is not a Blue Social User
                // isUser_ReferalConnect == false means that user is a Blue Social User
                print("isUser_ReferalConnect: \(profileVC.isUser_ReferalConnect)")
                
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = CATransitionType.moveIn
                transition.subtype = CATransitionSubtype.fromTop
                
                let navigationController = window?.rootViewController as? UINavigationController
                
                if UserLocalData.UserID == receiverID {
                    
                    if loginUser?.username == "" || loginUser?.username == nil || loginUser?.profile_img == "" || loginUser?.profile_img == nil { // Incomplete Profile
                        
                        let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
                        finishProfileVC.modalTransitionStyle = .crossDissolve
                        finishProfileVC.modalPresentationStyle = .overCurrentContext
                        navigationController?.present(finishProfileVC, animated: true)
                        
                    } else { // Completed Profile
                        
                        profileVC.navigationScreen = .currentUserProfile
                        navigationController?.view.layer.add(transition, forKey: kCATransition)
                        navigationController?.pushViewController(profileVC, animated: false)
                    }
                    
                } else {
                    
                    profileVC.navigationScreen = .notification
                    profileVC.receiver_id = receiverID
                    navigationController?.view.layer.add(transition, forKey: kCATransition)
                    navigationController?.pushViewController(profileVC, animated: false)
                }
            }
        }
        
        // Call the completion handler when you finish processing the notification
        completionHandler()
    }
    
    //    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    //        Messaging.messaging().apnsToken = deviceToken as Data
    //    }
    
    func stringFrom(dict: [AnyHashable: Any]) -> String? {
        
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
            if let json = String(data: data, encoding: .utf8) {
                return json
            }
        }
        return nil
    }
}

protocol PushNotificationDelegate {
    func didTapNotification(payloadData: NotificationPayloadData)
}

protocol ReceivedPushNotificationDelegate {
    func notificationReceived(payloadData: NotificationPayloadData)
}

// ----------------------------------------------------------
//                       MARK: - Dynamic Link -
// ----------------------------------------------------------
extension AppDelegate {
    
    // This method is used for handling incoming links when the app is already running and the user interacts with a supported link, such as a Universal Link. It is typically used to handle links that are received when the app is already in the foreground or background.
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if loginUser != nil {
            
            if let incomingURL = userActivity.webpageURL {
                
                if "\(incomingURL)".hasSuffix("?type=QR") {
                    
                    let modifiedURLString = "\(incomingURL)".replacingOccurrences(of: "?type=QR", with: "")
                    
                    let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
                    profileVC.navigationScreen = .dynamicLink
                    profileVC.slug = modifiedURLString
                    
                    // Use a custom transition
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromTop
                    
                    // When opens App on tap of Open in App Button from Browser, compare stringURL_endPoint with unique_url_endPoint instead of whole stringURL with unique_url. Because baseURL can be change from Backend.
                    let unique_url_endPoint = loginUser?.unique_url?.components(separatedBy: "/").last
                    let stringURL_endPoint = modifiedURLString.components(separatedBy: "/").last
                    
                    if unique_url_endPoint == stringURL_endPoint, loginUser?.username != nil, loginUser?.profile_img != nil {
                        profileVC.navigationScreen = .currentUserProfile
                    }
                    
                    let navigationController = window?.rootViewController as? UINavigationController
                    navigationController?.view.layer.add(transition, forKey: kCATransition)
                    
                    if let topVC = navigationController?.viewControllers.last, topVC is ProfileVC {
                        if let existingProfileVC = topVC as? ProfileVC {
                            navigationController?.viewControllers.removeAll(where: { $0 === existingProfileVC })
                        }
                    }
                    
                    if loginUser?.username == nil || loginUser?.profile_img == nil {
                        let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
                        finishProfileVC.modalTransitionStyle = .crossDissolve
                        finishProfileVC.modalPresentationStyle = .overCurrentContext
                        navigationController?.present(finishProfileVC, animated: true)
                    } else {
                        navigationController?.pushViewController(profileVC, animated: false)
                    }
                }
                
                _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (mainDynamicLink, error) in
                    
                    guard error == nil else {
                        print("error : \(error!.localizedDescription)")
                        return
                    }
                    
                    if let dynamicLink = mainDynamicLink {
                        self.handelIncomingDynamicLink(dynamicLink)
                    }
                }
                return true
            }
        }
        return false
    }
    
    // This method is used for handling incoming links when the app is launched as a result of the user clicking on a link, typically when the app is not already running. It is part of the newer URL handling mechanism introduced in iOS 9 and is used to handle Universal Links and other custom URL schemes.
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamicLink, error) in
            
            guard error == nil else {
                print("error : \(error!.localizedDescription)")
                return
            }
            
            if let dynamicLink = dynamicLink {
                self.handelIncomingDynamicLink(dynamicLink)
            }
        }
        
        if linkHandled {
            return true
        } else {
            return false
        }
    }
    
    func handelIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard UserLocalData.UserID != "", let url = dynamicLink.url else { return }
        
        let stringURL = url.absoluteString
        
        let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
        profileVC.navigationScreen = .dynamicLink
        profileVC.slug = stringURL
        
        // Use a custom transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        
        //        if loginUser?.unique_url == stringURL, loginUser?.username != nil, loginUser?.profile_img != nil {
        //            profileVC.navigationScreen = .currentUserProfile
        //        }
        
        // When opens App on tap of Open in App Button from Browser, compare stringURL_endPoint with unique_url_endPoint instead of whole stringURL with unique_url. Because baseURL can be change from Backend.
        let unique_url_endPoint = loginUser?.unique_url?.components(separatedBy: "/").last
        let stringURL_endPoint = stringURL.components(separatedBy: "/").last
        
        if unique_url_endPoint == stringURL_endPoint, loginUser?.username != nil, loginUser?.profile_img != nil {
            profileVC.navigationScreen = .currentUserProfile
        }
        
        let navigationController = window?.rootViewController as? UINavigationController
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        if let topVC = navigationController?.viewControllers.last, topVC is ProfileVC {
            if let existingProfileVC = topVC as? ProfileVC {
                navigationController?.viewControllers.removeAll(where: { $0 === existingProfileVC })
            }
        }
        
        if loginUser?.username == nil || loginUser?.profile_img == nil {
            let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
            finishProfileVC.modalTransitionStyle = .crossDissolve
            finishProfileVC.modalPresentationStyle = .overCurrentContext
            navigationController?.present(finishProfileVC, animated: true)
        } else {
            navigationController?.pushViewController(profileVC, animated: false)
        }
    }
}
