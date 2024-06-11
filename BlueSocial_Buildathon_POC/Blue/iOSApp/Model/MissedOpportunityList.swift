//
//  MissedOpportunityList.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

struct MissedOpportunityList: Mappable {
    
    var id                  : String?
    var user_id             : String?
    var receiver_id         : String?
    var lat                 : String?
    var lng                 : String?
    var device_scan_type    : String?
    var is_unlocked         : String?
    var dt_created          : String?
    var fullname            : String?
    var firstname           : String?
    var lastname            : String?
    var email               : String?
    var username            : String?
    var profile_url         : String?
    var redirect_url        : String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        id                  <- map["id"]
        user_id             <- map["user_id"]
        receiver_id         <- map["receiver_id"]
        lat                 <- map["lat"]
        lng                 <- map["lng"]
        device_scan_type    <- map["device_scan_type"]
        is_unlocked         <- map["is_unlocked"]
        dt_created          <- map["dt_created"]
        fullname            <- map["fullname"]
        firstname           <- map["firstname"]
        lastname            <- map["lastname"]
        email               <- map["email"]
        username            <- map["username"]
        profile_url         <- map["profile_url"]
        redirect_url        <- map["redirect_url"]
    }
}
