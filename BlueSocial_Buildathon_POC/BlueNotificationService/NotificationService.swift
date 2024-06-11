//
//  NotificationService.swift
//  BlueNotificationService
//
//  Created by Blue.

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // Modify the notification content here
        if let bestAttemptContent = bestAttemptContent {
            if let imageURLString = bestAttemptContent.userInfo["image"] as? String, let imageURL = URL(string: imageURLString) {
                downloadImage(from: imageURL) { image in
                    if let image = image, let attachment = self.saveImageAttachment(image) {
                        bestAttemptContent.attachments = [attachment]
                    }
                    contentHandler(bestAttemptContent)
                }
            } else {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
    
    private func saveImageAttachment(_ image: UIImage) -> UNNotificationAttachment? {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let uniqueName = ProcessInfo.processInfo.globallyUniqueString
        let fileURL = tempDir.appendingPathComponent("\(uniqueName).jpg")
        
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        do {
            try data.write(to: fileURL)
            return try UNNotificationAttachment(identifier: uniqueName, url: fileURL, options: nil)
        } catch {
            return nil
        }
    }
}
