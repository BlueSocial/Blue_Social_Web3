//
//  NotificationList.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class NotificationList: Mappable {
    
    var id                          : String?
    var user_id                     : String?
    var notificationTypeID          : String?
    var title                       : String?
    var message                     : String?
    var image_url                   : String?
    var is_admin                    : String?
    var created_at                  : String?
    var name                        : String?
    var profile_img                 : String?
    var isNotificationViewed        : Bool = false
    var notification_type_image     : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        id                          <- map["id"]
        user_id                     <- map["user_id"]
        notificationTypeID          <- map["notification_type_id"]
        title                       <- map["title"]
        message                     <- map["message"]
        image_url                   <- map["image_url"]
        is_admin                    <- map["is_admin"]
        created_at                  <- map["created_at"]
        name                        <- map["name"]
        profile_img                 <- map["profile_img"]
        isNotificationViewed        <- map["is_notification_viewed"]
        notification_type_image     <- map["notification_type_image"]
    }
}
