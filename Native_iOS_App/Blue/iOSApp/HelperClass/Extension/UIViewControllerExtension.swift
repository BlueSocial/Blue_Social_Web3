//
//  UIViewController.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit
import CoreLocation
import NearbyInteraction
import Photos
import MapKit

extension UIViewController: ReceivedPushNotificationDelegate {
    
    func notificationReceived(payloadData: NotificationPayloadData) {
        
        print("==========================================================================")
        print("view_type :: \(payloadData.view_type ?? "")")
        
        if let viewType = payloadData.view_type {
            
            switch viewType {
                    
                case NotificationType.BreakTheIceAccept.type():
                    
                    /*
                     
                     // NOTE: NISession.isSupported is a static property within the NISession class that determines whether the device running your iOS Swift application has the necessary hardware and software capabilities to support the Nearby Interaction (NI) framework.
                     
                     - Key factors that NISession.isSupported checks for:
                     
                     - Hardware compatibility:
                     Presence of the U1 chip (Ultra Wideband chip), which is essential for precise distance and direction estimation.
                     Compatibility of other hardware components required for NI functionality.
                     
                     - iOS version compatibility:
                     The device must be running iOS 14 or later, as NI was introduced in iOS 14.
                     
                     - Framework availability:
                     The NI framework itself must be available on the device.
                     
                     */
                    
                    if payloadData.isU1ChipAvailable == "1", #available(iOS 14.0, *), NISession.isSupported {
                        
                        print("::: uwbToken = \(payloadData.uwbToken ?? "") :::")
                        
                        print("::: U1Chip supported :::")
                        let nearbyDirectionVC = NearbyDirectionVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                        nearbyDirectionVC.nearbyUserID = payloadData.user_id ?? ""
                        nearbyDirectionVC.uwbToken = payloadData.uwbToken ?? ""
                        self.navigationController?.pushViewController(nearbyDirectionVC, animated: true)
                        
                    } else {
                        
                        print("::: U1Chip is not supported | Fallback on earlier versions | Android Device :::")
                        let nearbyDistanceVC = NearbyDistanceVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                        nearbyDistanceVC.nearbyUserID = payloadData.user_id ?? ""
                        self.navigationController?.pushViewController(nearbyDistanceVC, animated: true)
                    }
                    break
                    
                case NotificationType.InProcessReject.type():
                    
                    let nearbyDeclinedRequestVC = NearbyDeclinedRequestVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                    nearbyDeclinedRequestVC.nearbyUserID = payloadData.user_id ?? ""
                    self.navigationController?.pushViewController(nearbyDeclinedRequestVC, animated: true)
                    break
                    
                case NotificationType.InRange.type():
                    
                    if let topVC = UIApplication.getTopViewController() {
                        print(topVC)
                        
                        if (topVC is NearbyDistanceVC || topVC is NearbyDirectionVC) && !(topVC is NearbyProofOfInteractionVC) {
                            print("topVC is: \(topVC)")
                            
                            let nearbyProofOfInteractionVC = NearbyProofOfInteractionVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                            
                            let dbUserData = DBManager.checkUserSocialInfoExist(userID: payloadData.receiver_id ?? "")
                            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                                nearbyProofOfInteractionVC.nearbyUserDetail = dbUserModel
                            }
                            
                            self.navigationController?.pushViewController(nearbyProofOfInteractionVC, animated: true)
                            
                        } else {
                            print("topVC is not NearbyDistanceVC || NearbyDirectionVC")
                        }
                    }
                    break
                    
                default:
                    break
            }
        }
    }
}

extension UIViewController: PushNotificationDelegate {
    
    func currentDateTime() -> String {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    func currentDate() -> String {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func timeGapBetweenDates(previousDate: String, currentDate: String) -> Int {
        
        let dateString1 = previousDate
        let dateString2 = currentDate
        
        let Dateformatter = DateFormatter()
        Dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let date1 = Dateformatter.date(from: dateString1)
        let date2 = Dateformatter.date(from: dateString2)
        
        let distanceBetweenDates: TimeInterval? = date2?.timeIntervalSince(date1!)
        let secondsInAnHour: Double = 3600
        let minsInAnHour: Double = 60
        let secondsInDays: Double = 86400
        let secondsInWeek: Double = 604800
        let secondsInMonths : Double = 2592000
        let secondsInYears : Double = 31104000
        
        let minBetweenDates = Int((distanceBetweenDates! / minsInAnHour))
        let hoursBetweenDates = Int((distanceBetweenDates! / secondsInAnHour))
        let daysBetweenDates = Int((distanceBetweenDates! / secondsInDays))
        let weekBetweenDates = Int((distanceBetweenDates! / secondsInWeek))
        let monthsbetweenDates = Int((distanceBetweenDates! / secondsInMonths))
        let yearbetweenDates = Int((distanceBetweenDates! / secondsInYears))
        let secbetweenDates = Int(distanceBetweenDates!)
        
        if yearbetweenDates > 0 {
            print(yearbetweenDates,"years")//0 years
            
        } else if monthsbetweenDates > 0 {
            print(monthsbetweenDates,"months")//0 months
            
        } else if weekBetweenDates > 0 {
            print(weekBetweenDates,"weeks")//0 weeks
            
        } else if daysBetweenDates > 0 {
            print(daysBetweenDates,"days")//5 days
            
        } else if hoursBetweenDates > 0 {
            print(hoursBetweenDates,"hours")//120 hours
            
        } else if minBetweenDates > 0 {
            print(minBetweenDates,"minutes")//7200 minutes
            
        } else if secbetweenDates > 0 {
            print(secbetweenDates,"seconds")//seconds
        }
        
        return secbetweenDates
    }
    
    func setNotificationDelegate() {
        
        appDelegate.notificationDelegate = self
        appDelegate.notificationReceivedDelegate = self
    }
    
    func didTapNotification(payloadData: NotificationPayloadData) {
        
        print("==========================================================================")
        print("view_type :: \(payloadData.view_type ?? "")")
        
        if let viewType = payloadData.view_type {
            
            switch viewType {
                    
                case NotificationType.BreakTheIceSent.type():
                    
                    let nearbyRequestVC = NearbyRequestVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                    nearbyRequestVC.navigationScreen = .deviceHistory
                    nearbyRequestVC.nearbyUserID = payloadData.user_id ?? ""
                    nearbyRequestVC.uwbToken = payloadData.uwbToken ?? ""
                    nearbyRequestVC.isU1ChipAvailable = payloadData.isU1ChipAvailable ?? "0"
                    self.navigationController?.pushViewController(nearbyRequestVC, animated: true)
                    break
                    
                case NotificationType.BreakTheIceReject.type():
                    
                    let nearbyDeclinedRequestVC = NearbyDeclinedRequestVC.instantiate(fromAppStoryboard: .NearbyInteraction)
                    nearbyDeclinedRequestVC.nearbyUserID = payloadData.user_id ?? ""
                    self.navigationController?.pushViewController(nearbyDeclinedRequestVC, animated: true)
                    break
                    
                case NotificationType.Notification.type():
                    
                    break
                    
                default:
                    break
            }
        }
    }
    
    //Nikhil: Add this
    func shareActivityApp(items: [Any]) {
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.setValue("Connect with me on Blue 📲", forKey: "subject")
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            if !completed {
                // User canceled
                return
            }
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func getTodayDate() -> String {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    typealias completionLocation = ((CLLocation, Error?) -> Void)
    
    func getLatlongFrom(address: String, myCompletion: @escaping completionLocation) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else { return }
            
            myCompletion(location, nil)
        }
    }
    
    func openAppleMap(with address: String) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            if let error = error {
                print("Error geocoding address: \(error.localizedDescription)")
                self.openAppleMapForSearch(with: address)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("Could not find location for address: \(address)")
                self.openAppleMapForSearch(with: address)
                return
            }
            
            let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
            mapItem.name = address
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func openAppleMapForSearch(with searchQuery: String) {
        
        guard let encodedSearchQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error encoding search query.")
            return
        }
        
        if let url = URL(string: "http://maps.apple.com/?q=\(encodedSearchQuery)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Error creating URL for Apple Maps.")
        }
    }
    
    func showAlertWithOKButton(message: String, title: String = kAppName, btnTitle: String = kOk, _ completion: (() -> ())? = nil, _ dismissViewController: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okaction = UIAlertAction(title: btnTitle, style: .cancel) { (ok) in
            completion?()
            dismissViewController?()
        }
        alert.addAction(okaction)
        present(alert, animated: true, completion: nil)
        //UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWith2Buttons(title: String, message: String, btnOneName: String, btnTwoName: String, completion: @escaping  (_ btnAction: Int) -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: btnOneName, style: .default) { (action) in completion(1) }
        alert.addAction(action1)
        
        let action2 = UIAlertAction(title: btnTwoName, style: .default) { (UIAlertActionaction2) in completion(2) }
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertWith2ButtonswithColor(message: String, btnOneName: String, btnOneColor: UIColor, btnTwoName: String, btnTwoColor: UIColor, title: String = "", completion: @escaping (_ btnAction: Int) -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: btnOneName, style: .default) { (action) in completion(1) }
        alert.addAction(action1)
        
        let action2 = UIAlertAction(title: btnTwoName, style: .default) { (UIAlertActionaction2) in completion(2) }
        alert.addAction(action2)
        
        action1.setValue(btnOneColor, forKey: "titleTextColor")
        action2.setValue(btnTwoColor, forKey: "titleTextColor")
        
        present(alert, animated: true, completion: nil)
    }
    
    func makeToast(message: String) {
        let labelWidth: CGFloat = 150
        
        let xCoordinate = (self.view.frame.size.width - labelWidth) / 2
        let toastLabel = UILabel(frame: CGRect(x: xCoordinate, y: self.view.frame.size.height - 45, width: 150, height: 30))
        toastLabel.backgroundColor = UIColor.appBlack_000000().withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 15)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showImageOption(TitleMessage: String = "Change Profile Photo") {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //        let messageFont = [kCTFontAttributeName: UIFont(name: "Avenir-Roman", size: 18.0)!]
        //        let messageAttrString = NSMutableAttributedString(string: TitleMessage, attributes: messageFont as [NSAttributedString.Key: Any])
        //
        //        optionMenu.setValue(messageAttrString, forKey: "attributedMessage")
        
        let choosePhotoAction = UIAlertAction(title: kSelect_photo_from_gallery, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            ImagePicker().authorisationStatus(attachmentTypeEnum: .photoLibrary) { access in
                
                if access {
                    
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        
                        DispatchQueue.main.async {
                            imagePicker.sourceType = .photoLibrary
                            imagePicker.allowsEditing = false
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        
        let takePhotoAction = UIAlertAction(title: kCapture_photo_from_camera, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                ImagePicker().authorisationStatus(attachmentTypeEnum: .camera) { access in
                    
                    if access {
                        
                        DispatchQueue.main.async {
                            imagePicker.sourceType = .camera
                            imagePicker.cameraCaptureMode = .photo
                            imagePicker.allowsEditing = false
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: kCancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(choosePhotoAction)
        choosePhotoAction.setValue(UIColor.appBlack_000000(), forKey: "titleTextColor")
        optionMenu.addAction(takePhotoAction)
        takePhotoAction.setValue(UIColor.appBlack_000000(), forKey: "titleTextColor")
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func updateUserInfoInLocalDB(response: UserDetail) {
        
        let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
        
        if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
            
            let isUpdate = DBManager.updateSocialProfile(userID: dbUserData.userData?.id ?? "0", requestBody: dbUserModel.toJSONString()!)
            print("updatedata : \(isUpdate)")
        }
    }
    
    func getPhoneCodeDetail(strPhone: String) -> (String, String, String) {
        
        let newStrs = strPhone.split(separator: "_")
        
        if newStrs.count > 1 {
            
            //let strFlag = String((newStrs.first?.uppercased())!)
            let strFlag = "\(newStrs.first?.uppercased() ?? "")"
            let countryCode = "+\(String(newStrs[1]))"
            let phoneno = String(newStrs.count == 3 ? newStrs[2]: "")
            return (strFlag, countryCode, phoneno)
            
        } else {
            return ("US", "+1", "")
        }
    }

    func addAlertForSettings(_ attachmentTypeEnum: enumAttachmentType) {
        
        let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
        
        let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
        
        let alertForVideoLibraryMessage = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
        
        let settingsBtnTitle = "Settings"
        let cancelBtnTitle = "Cancel"
        
        let alertTitle: String = kAppName
        var alertMessage: String = ""
        
        if attachmentTypeEnum == enumAttachmentType.camera {
            //alertTitle = alertForCameraAccessMessage
            alertMessage = alertForCameraAccessMessage
        }
        
        if attachmentTypeEnum == enumAttachmentType.photoLibrary {
            //alertTitle = alertForPhotoLibraryMessage
            alertMessage = alertForPhotoLibraryMessage
        }
        
        if attachmentTypeEnum == enumAttachmentType.video {
            //alertTitle = alertForVideoLibraryMessage
            alertMessage = alertForVideoLibraryMessage
        }
        
        //let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
        let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: alertMessage, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: settingsBtnTitle, style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: cancelBtnTitle, style: .default, handler: nil)
        cameraUnavailableAlertController.addAction(cancelAction)
        cameraUnavailableAlertController.addAction(settingsAction)
        
        DispatchQueue.main.async {
            self.present(cameraUnavailableAlertController , animated: true, completion: nil)
        }
    }
    
    func topmostViewController() -> UIViewController {
        
        if let presentedViewController = presentedViewController {
            return presentedViewController.topmostViewController()
        }
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topmostViewController() ?? navigationController
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topmostViewController() ?? tabBarController
        }
        return self
    }
}

//extension Data {
//    
//    init?(hexString: String) {
//        let len = hexString.count / 2
//        var data = Data(capacity: len)
//        var i = hexString.startIndex
//        for _ in 0..<len {
//            let j = hexString.index(i, offsetBy: 2)
//            let bytes = hexString[i..<j]
//            if var num = UInt8(bytes, radix: 16) {
//                data.append(&num, count: 1)
//            } else {
//                return nil
//            }
//            i = j
//        }
//        self = data
//    }
//}

extension Data {
    
    init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "0x", with: "")
        
        var data = Data(capacity: hexSanitized.count / 2)
        var index = hexSanitized.startIndex
        
        while index < hexSanitized.endIndex {
            let nextIndex = hexSanitized.index(index, offsetBy: 2)
            let byte = hexSanitized[index..<nextIndex]
            
            if var num = UInt8(byte, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            
            index = nextIndex
        }
        
        self = data
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIViewController {
    
    func openURLToExternalBrowser(url: String) {
        
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
