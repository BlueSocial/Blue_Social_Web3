//
//  NotificationViewController.swift
//  BlueNotificationExtension
//
//  Created by Blue.

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var img_notification: UIImageView?
    @IBOutlet weak var btnYes: UIButton?
    @IBOutlet weak var btnNo: UIButton?
    @IBOutlet weak var lblHeader: UILabel?
    @IBOutlet weak var lblDesc: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
//    func didReceive(_ notification: UNNotification) {
//        
//        let content = notification.request.content
//        print("content: \(content)")
//        
//        if let fcmOptions = content.userInfo["fcm_options"] as? [AnyHashable: Any],
//           let imageUrl = fcmOptions["image"] as? String {
//            // Use imageUrl as needed (e.g., load an image from this URL)
//            print("Image URL: \(imageUrl)")
//            
//            if let url = URL(string: imageUrl), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                self.img_notification?.image = image
//            }
//            
//        } else {
//            // Handle the case where "image" key is not present or not of the expected type
//            print("No image URL found in the payload.")
//        }
//    }
    
    func didReceive(_ notification: UNNotification) {
        
        let content = notification.request.content
        lblHeader?.text = content.title
        lblDesc?.text = content.body
        
        // Load image from URL
        if let imageURLString = content.userInfo["image"] as? String, let imageURL = URL(string: imageURLString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.img_notification?.image = image
                    }
                }
            }
        }
    }
}
