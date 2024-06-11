//
//  DeviceScanHistory.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

struct DeviceScanHistory: Mappable {
    
    var receiver_id         : String?
    var id                  : String?
    var fullname            : String?
    var username            : String?
    var device_scan_type    : String?
    var profile_url         : String?
    var redirect_url        : String?
    var dt_created          : String?
    var isPremiumUser       : String?
    var userLatitude        : Double?
    var userLongitude       : Double?
    var title               : String?
    var company_name        : String?
    var firstname           : String?
    var lastname            : String?
    var email               : String?
    var profileImage        : UIImage?
    var referal_connect     : String?
    var university          : String?
    var profession_type     : String?
    var notes               : String?
    var duration            : String?
    var bst                 : String?
    var isProfileVisited    : Bool?
    var label               : Array<String>?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        receiver_id         <- map["receiver_id"]
        id                  <- map["id"]
        fullname            <- map["fullname"]
        username            <- map["username"]
        device_scan_type    <- map["device_scan_type"]
        profile_url         <- map["profile_url"]
        redirect_url        <- map["redirect_url"]
        dt_created          <- map["dt_created"]
        isPremiumUser       <- map["is_premium"]//map["isPremiumUser"]
        userLatitude        <- map["lat"]
        userLongitude       <- map["lng"]
        title               <- map["title"]
        company_name        <- map["company_name"]
        firstname           <- map["firstname"]
        lastname            <- map["lastname"]
        email               <- map["email"]
        profileImage        <- map["profileImage"]
        referal_connect     <- map["referal_connect"]
        university          <- map["university"]
        profession_type     <- map["profession_type"]
        notes               <- map["notes"]
        duration            <- map["duration"]
        bst                 <- map["bst"]
        isProfileVisited    <- map["is_profile_visited"]
        label               <- map["label"]
    }
}
