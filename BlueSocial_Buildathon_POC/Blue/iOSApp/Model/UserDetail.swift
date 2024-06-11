//
//  UserDetail.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

struct UserDetail: Mappable {
    
    var id                                          : String?
    var firstname                                   : String?
    var lastname                                    : String?
    var name                                        : String?
    var email                                       : String?
    var password                                    : String?
    var profile_img                                 : String?
    var business_profileURL                         : String?
    var profile_bg                                  : String?
    var class_of_year                               : String?
    var major                                       : String?
    var bio                                         : String?
    var business_bio                                : String?
    var business_firstName                          : String?
    var business_lastName                           : String?
    var business_username                           : String?
    var business_company                            : String?
    var business_title                              : String?
    var address                                     : String?
    var website                                     : String?
    var lat                                         : Double?
    var lng                                         : Double?
    var slug                                        : String?
    var view_counts                                 : String?
    var has_affiliate                               : String?
    var is_premium                                  : String?
    var company_name                                : String?
    var title                                       : String?
    var last_login                                  : String?
    var created_by                                  : String?
    var created_at                                  : String?
    var is_deleted                                  : String?
    var is_auth                                     : String?
    var is_list_grid                                : String?
    var is_email_verify                             : String?
    var is_profile_completed                        : String?
    var app_version                                 : String?
    var user_type                                   : String?
    var profession_type                             : String?
    var userInterest                                : [User_Interest]?
    var isactive                                    : String?
    var gender                                      : String?
    var dob                                         : String?
    var phone                                       : String?
    var username                                    : String?
    var affliate_url                                : String?
    var push_token                                  : String?
    var device_type                                 : String?
    var unique_id                                   : String?
    var survey_count                                : String?
    var survey_date                                 : String?
    var hash                                        : String?
    var ble_adv_token                               : String?
    var productPlanCounter                          : String?
    var discountCode                                : String?
    var refCode                                     : String?
    var bluetoothMode                               : String?
    var user_mode                                   : String?
    var private_mode                                : String?
    var private_mode_list                           : [PrivateModeList]?
    var missed_oppurtunities                        : String?
    var business_private_mode                       : String?
    var business_private_mode_list                  : [BusinessPrivateModeList]?
    var business_missed_oppurtunities               : String?
    var totalBST                                    : Int?
    var product_id                                  : String?
    var mobile                                      : String?
    var s_email                                     : String?
    var resume                                      : String?
    var age                                         : String?
    var userAffiliateLink                           : String?
    var unique_url                                  : String?
    var session_id                                  : String?
    var social_network                              : [Social_Network]?
    var subscriptionStatus                          : String?
    var shareprofile                                : String?
    var shareData                                   : ShareData?
    var interactions                                : String?
    var business_link                               : String?
    var business_network                            : [Social_Network]?
    var business_profilelink                        : String?
    var new_interaction                             : Int?
    var ble_ads                                     : String?
    var isTapSocial                                 = false
    var university                                  : String?
    var business_university                         : String?
    var linksTapped                                 : String?
    var distanceInMeter                             : Double?
    var caption                                     : String?
    var peripheralUUID                              : String?
    var referral_invite_url                         : String?
    var current_date                                : String?
    var current_subscription_expiry_date            : String?
    var history_subscription_expiry_date            : String?
    var subscription_transaction_id                 : String?
    
    init() {}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        id                               <- map["id"]
        name                             <- map["name"]
        email                            <- map["email"]
        password                         <- map["password"]
        profile_img                      <- map["profile_img"]
        class_of_year                    <- map["class_of_year"]
        major                            <- map["major"]
        bio                              <- map["bio"]
        address                          <- map["address"]
        lat                              <- map["lat"]
        lng                              <- map["lng"]
        slug                             <- map["slug"]
        view_counts                      <- map["view_counts"]
        has_affiliate                    <- map["has_affiliate"]
        is_premium                       <- map["is_premium"]
        last_login                       <- map["last_login"]
        created_by                       <- map["created_by"]
        created_at                       <- map["created_at"]
        is_deleted                       <- map["is_deleted"]
        user_type                        <- map["user_type"]
        isactive                         <- map["isactive"]
        gender                           <- map["gender"]
        dob                              <- map["dob"]
        mobile                           <- map["mobile"]
        username                         <- map["username"]
        affliate_url                     <- map["affliate_url"]
        device_type                      <- map["device_type"]
        push_token                       <- map["push_token"]
        unique_id                        <- map["unique_id"]
        hash                             <- map["hash"]
        profile_bg                       <- map["profile_bg"]
        resume                           <- map["resume"]
        age                              <- map["age"]
        userAffiliateLink                <- map["userAffiliateLink"]
        unique_url                       <- map["unique_url"]
        session_id                       <- map["session_id"]
        company_name                     <- map["company_name"]
        title                            <- map["title"]
        is_list_grid                     <- map["is_list_grid"]
        is_auth                          <- map["is_auth"]
        is_email_verify                  <- map["is_email_verify"]
        isTapSocial                      <- map["isTapSocial"]
        social_network                   <- map["social_network"]
        productPlanCounter               <- map["product_plan_counter"]
        discountCode                     <- map["discount_code"]
        refCode                          <- map["ref_code"]
        bluetoothMode                    <- map["bluetooth_mode"]
        subscriptionStatus               <- map["subscription_status"]
        shareprofile                     <- map["share_profile"]
        shareData                        <- map["share_data"]
        firstname                        <- map["firstname"]
        lastname                         <- map["lastname"]
        interactions                     <- map["interactions"]
        business_firstName               <- map["business_firstname"]
        business_lastName                <- map["business_lastname"]
        business_username                <- map["business_username"]
        business_company                 <- map["business_company"]
        business_title                   <- map["business_title"]
        business_bio                     <- map["business_bio"]
        business_network                 <- map["business_network"]
        business_link                    <- map["business_link"]
        business_profileURL              <- map["business_profile_pic"]
        business_profilelink             <- map["business_profilelink"]
        user_mode                        <- map["user_mode"]
        new_interaction                  <- map["new_interaction"]
        ble_ads                          <- map["ble_ads"]
        totalBST                         <- map["total_bst"]
        userInterest                     <- map["user_interest"]
        private_mode                     <- map["private_mode"]
        private_mode_list                <- map["private_mode_list"]
        business_private_mode            <- map["business_private_mode"]
        business_private_mode_list       <- map["business_private_mode_list"]
        profession_type                  <- map["profession_type"]
        is_profile_completed             <- map["is_profile_completed"]
        university                       <- map["university"]
        business_university              <- map["business_university"]
        linksTapped                      <- map["linksTapped"]
        caption                          <- map["caption"]
        peripheralUUID                   <- map["peripheral_uuid"]
        referral_invite_url              <- map["referral_invite_url"]
        current_date                     <- map["current_date"]
        current_subscription_expiry_date <- map["current_subscription_expiry_date"]
        history_subscription_expiry_date <- map["history_subscription_expiry_date"]
        subscription_transaction_id      <- map["subscription_transaction_id"]
    }
}

class User_Interest: NSObject, Mappable, NSCoding, NSSecureCoding {
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    var id                          : String?
    var name                        : String?
    var icon                        : String?
    var selected                    : Bool = false
    var isNewInterestTopic          : Bool
    
    required init?(map: Map) {
        // Initialize isNewInterestTopic to false when the instance is created from the API.
        isNewInterestTopic = false
    }
    
    // Add a custom initializer
    init(id: String, name: String, icon: String, selected: Bool, isNewInterestTopic: Bool) {
        self.id = id
        self.name = name
        self.icon = icon
        self.selected = selected
        self.isNewInterestTopic = isNewInterestTopic
    }
    
    func toggleSelection() {
        selected = !selected
    }
    
    func mapping(map: Map) {
        
        id                          <- map["id"]
        name                        <- map["name"]
        icon                        <- map["icon"]
        selected                    <- map["selected"]
    }
    
    // MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(selected, forKey: "selected")
        aCoder.encode(isNewInterestTopic, forKey: "isNewInterestTopic")
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        icon = aDecoder.decodeObject(forKey: "icon") as? String
        selected = aDecoder.decodeBool(forKey: "selected")
        isNewInterestTopic = aDecoder.decodeBool(forKey: "isNewInterestTopic")
    }
}

class PrivateModeList: Mappable {
    
    var name                        : String?
    var selected                    : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        name                        <- map["name"]
        selected                    <- map["selected"]
    }
}

class BusinessPrivateModeList: Mappable {
    
    var name                        : String?
    var selected                    : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        name                        <- map["name"]
        selected                    <- map["selected"]
    }
}

class ShareData: Mappable {
    
    var Link                    : String?
    var Title                   : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        Link                    <- map["link"]
        Title                   <- map["title"]
    }
}
