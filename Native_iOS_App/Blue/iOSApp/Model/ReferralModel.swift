//
//  ReferralModel.swift
//  Blue
//
//  Created by Blue.

import Foundation
import ObjectMapper

class ReferralInviteDataModel: Mappable {
    
    var ref_user_id          : String?
    var name                 : String?
    var profile_img          : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        ref_user_id                          <- map["ref_user_id"]
        name                                 <- map["name"]
        profile_img                          <- map["profile_img"]
        
    }
}

class ReferralInsightsDataModel: Mappable {
    var x: [String]?
    var tokensEarned: [String]?
    var successfulReferral: [String]?
    var tokensEarnedMax: String?
    var successfulReferralMax: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        x <- map["x"]
        tokensEarned <- map["tokensEarned"]
        successfulReferral <- map["successfulReferral"]
        tokensEarnedMax <- map["tokensEarnedMax"]
        successfulReferralMax <- map["successfulReferralMax"]
    }
}
