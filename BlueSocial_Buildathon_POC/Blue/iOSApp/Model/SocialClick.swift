//
//  SocialClick.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class SocialClick: Mappable {
    
    var createdAt                   : String?
    var id                          : String?
    var key                         : String?
    var type                        : String?
    private var val                 : String?
    var social                      : ClickValue?
    var clickData                   : [SocialListNetwork]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        createdAt                   <- map["created_at"]
        id                          <- map["id"]
        key                         <- map["key"]
        type                        <- map["type"]
        val                         <- map["val"]
        social                      = ClickValue(JSONString: val ?? "")
        clickData                   <- map["clickData"]
    }
}

class SocialListNetwork: Mappable {
    
    var social_category_title       : String?
    var seq_order                   : String?
    var social_network_list         : [SocialNetworks]?
    var Social_networkExpand        : Bool = false
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        social_category_title       <- map["social_category_title"]
        seq_order                   <- map["seq_order"]
        social_network_list         <- map["social_network_list"]
    }
}

class SocialNetworks: Mappable {
    
    var social_name                 : String?
    var sid                         : String?
    var social_icon                 : String?
    var value                       : Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        social_name                 <- map["social_name"]
        sid                         <- map["sid"]
        social_icon                 <- map["social_icon"]
        value                       <- map["value"]
    }
}

// TapSoicalClick
class NotificationPayloadData: Mappable {
    
    required init?(map: Map) {}
    
    var sender_id                   : String?
    var receiver_id                 : String?
    var isTapSocial                 : Bool?
    var sender_name                 : String?
    var message                     : String?
    var notify                      : String?
    var fromUserID                  : String?
    var toUserID                    : String?
    var broadcastType               : String?
    var data                        : EventData?
    //InviteNotification
    var user_id                     : String?
    // var receiver_id              : String?
    var view_type                   : String?
    var isBeacon                    : Bool?
    var uuid                        : Int?
    var description                 : String?
    var title                       : String?
    var major                       : Int?
    var favicon                     : String?
    var beaconid                    : String?
    var minor                       : Int?
    var BLEToken                    : String?
    var BLEAds                      : String?
    var receivedToken               : String?
    var uwbToken                    : String?
    var isU1ChipAvailable           : String? // "0" - false, "1" - true
    
    func mapping(map: Map) {
        
        sender_id                   <- map["sender_id"]
        receiver_id                 <- map["receiver_id"]
        isTapSocial                 <- map["isTapSocial"]
        sender_name                 <- map["sender_name"]
        message                     <- map["message"]
        fromUserID                  <- map["fromUserID"]
        toUserID                    <- map["toUserID"]
        broadcastType               <- map["broadcastType"]
        data                        <- map["data"]
        //InviteNotification
        user_id                     <- map["user_id"]
        view_type                   <- map["view_type"]
        notify                      <- map["notify"]
        isBeacon                    <- map["isBeacon"]
        uuid                        <- map["uuid"]
        description                 <- map["description"]
        title                       <- map["title"]
        major                       <- map["major"]
        favicon                     <- map["favicon"]
        beaconid                    <- map["beaconid"]
        minor                       <- map["minor"]
        isBeacon                    <- map["isBeacon"]
        uuid                        <- map["uuid"]
        BLEToken                    <- map["BLEToken"]
        BLEAds                      <- map["bleads"]
        receivedToken               <- map["bst"]
        uwbToken                    <- map["uwb_token"]
        isU1ChipAvailable           <- map["is_u1_chip_available"]
    }
}

class EventData: Mappable {
    
    var eventID                     : String?
    var userID                      : String?
    var shouldShowUser              : Bool?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        eventID                     <- map["eventID"]
        userID                      <- map["userID"]
        shouldShowUser              <- map["shouldShowUser"]
    }
}
