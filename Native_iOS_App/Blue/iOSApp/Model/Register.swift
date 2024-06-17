//
//  Register.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class Register: Mappable {
    
    var flag                        : String?
    var name                        : String?
    var email                       : String?
    var password                    : String?
    var push_token                  : String?
    var device_type                 : String?
    var mobile                      : String?
    var dob                         : String?
    var gender                      : String?
    var age                         : String?
    var id                          : String?
    var unique_url                  : String?
    var session_id                  : String?
    var unique_id                   : String?
    var company_name                : String?
    var title                       : String?
    var type                        : String?
    var is_auth                     : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        flag                        <- map["flag"]
        name                        <- map["name"]
        email                       <- map["email"]
        password                    <- map["password"]
        push_token                  <- map["push_token"]
        device_type                 <- map["device_type"]
        mobile                      <- map["mobile"]
        dob                         <- map["dob"]
        age                         <- map["age"]
        id                          <- map["id"]
        unique_url                  <- map["unique_url"]
        session_id                  <- map["session_id"]
        unique_id                   <- map["unique_id"]
        company_name                <- map["company_name"]
        title                       <- map["title"]
        type                        <- map["type"]
        is_auth                     <- map["is_auth"]
        gender                      <- map["genders"]
    }
}

class Selfie : Mappable {
    
    var flag                        : String?
    var userid                      : String?
    var profile_img                 : String?
    var profile_bg                  : String?
    var type                        : String?
    var resume                      : String?
    var uploadedURL                 : String?
    var filename                    : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        flag                        <- map["flag"]
        userid                      <- map["userid"]
        profile_img                 <- map["profile_img"]
        type                        <- map["type"]
        profile_bg                  <- map["profile_bg"]
        resume                      <- map["resume"]
        uploadedURL                 <- map["uploadedurl"]
        filename                    <- map["filename"]
    }
}

//----------------------------------------------------------------------------------------------------
// MARK: - NOT USED -
//----------------------------------------------------------------------------------------------------
//class yourself : Mappable {
//    
//    var flag                        : String?
//    var userid                      : String?
//    var bio                         : String?
//    
//    required init?(map: Map) {}
//    
//    func mapping(map: Map) {
//        
//        flag                        <- map["flag"]
//        userid                      <- map["userid"]
//        bio                         <- map["bio"]
//    }
//}

//class SocialNetwork : Mappable {
//    
//    var flag                        : String?
//    var userid                      : String?
//    var lat                         : String?
//    var long                        : String?
//    var address                     : String?
//    var instagram                   : String?
//    var snapchat                    : String?
//    var twitter                     : String?
//    var facebook                    : String?
//    var linkedin                    : String?
//    var venmo                       : String?
//    var youtube                     : String?
//    var pinterest                   : String?
//    var whatsapp                    : String?
//    var applemusic                  : String?
//    var spotify                     : String?
//    var website                     : String?
//    var link                        : String?
//    var phone                       : String?
//    var s_email                     : String?
//    var paypal                      : String?
//    var soundcloud                  : String?
//    var tidal                       : String?
//    var tiktok                      : String?
//    var cashapp                     : String?
//    var twitch                      : String?
//    var patreon                     : String?
//    var amazon                      : String?
//    var applepodcasts               : String?
//    var zelle                       : String?
//    var telegram                    : String?
//    var slack                       : String?
//    var discord                     : String?
//    var yelp                        : String?
//    var etsy                        : String?
//    var tumblr                      : String?
//    var vimeo                       : String?
//    var houseparty                  : String?
//    var calendly                    : String?
//    var wechat                      : String?
//    var ordering                    : [String]?
//    
//    required init?(map: Map) {}
//    
//    func mapping(map: Map) {
//        
//        flag                        <- map["flag"]
//        userid                      <- map["userid"]
//        lat                         <- map["lat"]
//        long                        <- map["long"]
//        address                     <- map["address"]
//        instagram                   <- map["instagram"]
//        snapchat                    <- map["snapchat"]
//        twitter                     <- map["twitter"]
//        facebook                    <- map["facebook"]
//        linkedin                    <- map["linkedin"]
//        venmo                       <- map["venmo"]
//        youtube                     <- map["youtube"]
//        pinterest                   <- map["pinterest"]
//        whatsapp                    <- map["whatsapp"]
//        applemusic                  <- map["applemusic"]
//        spotify                     <- map["spotify"]
//        website                     <- map["website"]
//        link                        <- map["link"]
//        phone                       <- map["phone"]
//        s_email                     <- map["s_email"]
//        paypal                      <- map["paypal"]
//        soundcloud                  <- map["soundcloud"]
//        tidal                       <- map["tidal"]
//        tiktok                      <- map["tiktok"]
//        cashapp                     <- map["cashapp"]
//        twitch                      <- map["twitch"]
//        patreon                     <- map["patreon"]
//        amazon                      <- map["amazon"]
//        applepodcasts               <- map["applepodcasts"]
//        zelle                       <- map["zelle"]
//        telegram                    <- map["telegram"]
//        slack                       <- map["slack"]
//        discord                     <- map["discord"]
//        yelp                        <- map["yelp"]
//        etsy                        <- map["etsy"]
//        tumblr                      <- map["tumblr"]
//        vimeo                       <- map["vimeo"]
//        houseparty                  <- map["houseparty"]
//        calendly                    <- map["calendly"]
//        wechat                      <- map["wechat"]
//        ordering                    <- map["ordering"]
//    }
//}

//struct ProofOfInteractionUserHistory: Mappable {
//
//    var id                  : String?
//    var receiver_id         : String?
//    var sender_id           : String?
//    var fullname            : String?
//    var firstname           : String?
//    var lastname            : String?
//    var username            : String?
//    var duration            : String?
//    var userLatitude        : Double?
//    var userLongitude       : Double?
//    var dt_created          : String?
//    var profile_url         : String?
//    var isPremiumUser       : String?
//    var title               : String?
//    var profileImage        : UIImage?
//
//    init?(map: Map) {}
//
//    mutating func mapping(map: Map) {
//
//        id                  <- map["id"]
//        receiver_id         <- map["receiver_id"]
//        sender_id           <- map["sender_id"]
//        fullname            <- map["fullname"]
//        firstname           <- map["firstname"]
//        lastname            <- map["lastname"]
//        username            <- map["username"]
//        duration            <- map["duration"]
//        userLatitude        <- map["lat"]
//        userLongitude       <- map["lng"]
//        dt_created          <- map["dt_created"]
//        profile_url         <- map["profile_url"]
//        isPremiumUser       <- map["isPremiumUser"]
//        title               <- map["title"]
//        profileImage        <- map["profileImage"]
//    }
//}

//class MobileNumber : Mappable {
//    
//    var flag                        : String?
//    var userid                      : String?
//    var push_token                  : String?
//    var mobile                      : String?
//    var unique_id                   : String?
//    
//    required init?(map: Map) {}
//    
//    func mapping(map: Map) {
//        
//        flag                        <- map["flag"]
//        userid                      <- map["userid"]
//        push_token                  <- map["push_token"]
//        mobile                      <- map["mobile"]
//        unique_id                   <- map["unique_id"]
//    }
//}

//class MyEventList: Mappable {
//
//    var id                      : String?
//    var title                   : String?
//    var description             : String?
//    var location                : String?
//    var start_date              : String?
//    var end_date                : String?
//    var status                  : String?
//    var cover_image             : String?
//    var link                    : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        id                      <- map["id"]
//        title                   <- map["title"]
//        description             <- map["description"]
//        location                <- map["location"]
//        start_date              <- map["start_date"]
//        end_date                <- map["end_date"]
//        status                  <- map["status"]
//        cover_image             <- map["cover_image"]
//        link                    <- map["link"]
//    }
//}

//class MyEventDetails: Mappable {
//
//    var event                   : Event?
//    var eventViewer             : [EventViewer]?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map)  {
//
//        event                   <- map["event"]
//        eventViewer             <- map["event_viewer"]
//    }
//}

//struct EventViewer : Mappable {
//
//    var id                      : String?
//    var user_id                 : String?
//    var created_at              : String?
//    var name                    : String?
//    var profile_img             : String?
//
//    init?(map: Map) {}
//
//    mutating func mapping(map: Map) {
//
//        id                      <- map["id"]
//        user_id                 <- map["user_id"]
//        created_at              <- map["created_at"]
//        name                    <- map["name"]
//        profile_img             <- map["profile_img"]
//    }
//}

//class Event: Mappable {
//
//    var id                      : String?
//    var title                   : String?
//    var description             : String?
//    var location                : String?
//    var start_date              : String?
//    var end_date                : String?
//    var status                  : String?
//    var cover_image             : String?
//    var link                    : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        id                      <- map["id"]
//        title                   <- map["title"]
//        description             <- map["description"]
//        location                <- map["location"]
//        start_date              <- map["start_date"]
//        end_date                <- map["end_date"]
//        status                  <- map["status"]
//        cover_image             <- map["cover_image"]
//        link                    <- map["link"]
//    }
//}

//class ReferralsList: Mappable {
//
//    var referral                    : [Referral]?
//    var user_credit_point           : Int?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        referral                    <- map["referral"]
//        user_credit_point           <- map["user_credit_point"]
//    }
//}

//class Referral: Mappable {
//
//    var id                          : String?
//    var user_id                     : String?
//    var created_at                  : String?
//    var use_status                  : String?
//    var name                        : String?
//    var profile_img                 : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        id                          <- map["id"]
//        user_id                     <- map["user_id"]
//        created_at                  <- map["created_at"]
//        use_status                  <- map["use_status"]
//        name                        <- map["name"]
//        profile_img                 <- map["profile_img"]
//    }
//}

//class NotificationViewModel: Mappable {
//
//    var id                      : Int?
//    var title                   : String?
//    var subtitle                : String?
//    var loginUserID             : String?
//    var userid                  : String?
//    var type                    : String?
//    var status                  : String?
//    var time                    : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        id                      <- map["id"]
//        title                   <- map["title"]
//        subtitle                <- map["subtitle"]
//        loginUserID             <- map["loginUserID"]
//        userid                  <- map["userid"]
//        type                    <- map["type"]
//        status                  <- map["status"]
//        time                    <- map["time"]
//    }
//}

//class Topic: Mappable {
//
//    var id                          : String?
//    var topic                       : String?
//    var isSelected                  : Bool = false
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        id                          <- map["id"]
//        topic                       <- map["topic"]
//    }
//}

//class ProductDataList: Mappable {
//
//    var product_name                    : String?
//    var product_image                   : String?
//    var id                              : String?
//    var amount                          : String?
//    var plan_type                       : String?
//    var referrals_count                 : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        product_name                    <- map["product_name"]
//        product_image                   <- map["product_image"]
//        id                              <- map["id"]
//        amount                          <- map["amount"]
//        plan_type                       <- map["plan_type"]
//        referrals_count                 <- map["referrals_count"]
//    }
//}

//class GetInfo: Mappable {
//
//    var id                                  : String?
//    var name                                : String?
//    var email                               : String?
//    var password                            : String?
//    var profile_img                         : String?
//    var profile_bg                          : String?
//    var class_of_year                       : String?
//    var major                               : String?
//    var bio                                 : String?
//    var address                             : String?
//    var lat                                 : String?
//    var lng                                 : String?
//    var slug                                : String?
//    var view_counts                         : String?
//    var has_affiliate                       : String?
//    var is_premium                          : String?
//    var company_name                        : String?
//    var title                               : String?
//    var last_login                          : String?
//    var created_by                          : String?
//    var created_at                          : String?
//    var is_deleted                          : String?
//    var is_auth                             : String?
//    var is_list_grid                        : String?
//    var is_email_verify                     : String?
//    var app_version                         : String?
//    var user_type                           : String?
//    var isactive                            : String?
//    var gender                              : String?
//    var dob                                 : String?
//    var phone                               : String?
//    var username                            : String?
//    var affliate_url                        : String?
//    var push_token                          : String?
//    var device_type                         : String?
//    var unique_id                           : String?
//    var survey_count                        : String?
//    var survey_date                         : String?
//    var hash                                : String?
//    var product_plan_counter                : String?
//    var discount_code                       : String?
//    var ref_code                            : String?
//    var bluetooth_mode                      : String?
//    var enterprise_id                       : String?
//    var uniqid                              : String?
//    var mobile                              : String?
//    var instagram                           : String?
//    var snapchat                            : String?
//    var twitter                             : String?
//    var facebook                            : String?
//    var linkedin                            : String?
//    var venmo                               : String?
//    var youtube                             : String?
//    var pinterest                           : String?
//    var applemusic                          : String?
//    var whatsapp                            : String?
//    var spotify                             : String?
//    var website                             : String?
//    var link                                : String?
//    var s_email                             : String?
//    var paypal                              : String?
//    var soundcloud                          : String?
//    var tidal                               : String?
//    var tiktok                              : String?
//    var cashapp                             : String?
//    var twitch                              : String?
//    var patreon                             : String?
//    var amazon                              : String?
//    var applepodcasts                       : String?
//    var zelle                               : String?
//    var telegram                            : String?
//    var slack                               : String?
//    var discord                             : String?
//    var yelp                                : String?
//    var etsy                                : String?
//    var tumblr                              : String?
//    var vimeo                               : String?
//    var houseparty                          : String?
//    var calendly                            : String?
//    var wechat                              : String?
//    var resume                              : String?
//    var ordering                            : [String]?
//    var social_network                      : [Social_Network]?
//    var unique_url                          : String?
//    var affiliate                           : Int?
//    var userAffiliateLink                   : String?
//    var age                                 : String?
//    var productPlanCounter                  : String?
//    var discountCode                        : String?
//    var refCode                             : String?
//    var bluetoothMode                       : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        id                                  <- map["id"]
//        name                                <- map["name"]
//        email                               <- map["email"]
//        password                            <- map["password"]
//        profile_img                         <- map["profile_img"]
//        profile_bg                          <- map["profile_bg"]
//        class_of_year                       <- map["class_of_year"]
//        major                               <- map["major"]
//        bio                                 <- map["bio"]
//        address                             <- map["address"]
//        lat                                 <- map["lat"]
//        lng                                 <- map["lng"]
//        slug                                <- map["slug"]
//        view_counts                         <- map["view_counts"]
//        has_affiliate                       <- map["has_affiliate"]
//        is_premium                          <- map["is_premium"]
//        company_name                        <- map["company_name"]
//        title                               <- map["title"]
//        last_login                          <- map["last_login"]
//        created_by                          <- map["created_by"]
//        created_at                          <- map["created_at"]
//        is_deleted                          <- map["is_deleted"]
//        is_auth                             <- map["is_auth"]
//        is_list_grid                        <- map["is_list_grid"]
//        is_email_verify                     <- map["is_email_verify"]
//        app_version                         <- map["app_version"]
//        user_type                           <- map["user_type"]
//        isactive                            <- map["isactive"]
//        gender                              <- map["gender"]
//        dob                                 <- map["dob"]
//        phone                               <- map["phone"]
//        username                            <- map["username"]
//        affliate_url                        <- map["affliate_url"]
//        push_token                          <- map["push_token"]
//        device_type                         <- map["device_type"]
//        unique_id                           <- map["unique_id"]
//        survey_count                        <- map["survey_count"]
//        survey_date                         <- map["survey_date"]
//        hash                                <- map["hash"]
//        product_plan_counter                <- map["product_plan_counter"]
//        discount_code                       <- map["discount_code"]
//        ref_code                            <- map["ref_code"]
//        bluetooth_mode                      <- map["bluetooth_mode"]
//        enterprise_id                       <- map["enterprise_id"]
//        uniqid                              <- map["uniqid"]
//        mobile                              <- map["mobile"]
//        instagram                           <- map["instagram"]
//        snapchat                            <- map["snapchat"]
//        twitter                             <- map["twitter"]
//        facebook                            <- map["facebook"]
//        linkedin                            <- map["linkedin"]
//        venmo                               <- map["venmo"]
//        youtube                             <- map["youtube"]
//        pinterest                           <- map["pinterest"]
//        applemusic                          <- map["applemusic"]
//        whatsapp                            <- map["whatsapp"]
//        spotify                             <- map["spotify"]
//        website                             <- map["website"]
//        link                                <- map["link"]
//        s_email                             <- map["s_email"]
//        paypal                              <- map["paypal"]
//        soundcloud                          <- map["soundcloud"]
//        tidal                               <- map["tidal"]
//        tiktok                              <- map["tiktok"]
//        cashapp                             <- map["cashapp"]
//        twitch                              <- map["twitch"]
//        patreon                             <- map["patreon"]
//        amazon                              <- map["amazon"]
//        applepodcasts                       <- map["applepodcasts"]
//        zelle                               <- map["zelle"]
//        telegram                            <- map["telegram"]
//        slack                               <- map["slack"]
//        discord                             <- map["discord"]
//        yelp                                <- map["yelp"]
//        etsy                                <- map["etsy"]
//        tumblr                              <- map["tumblr"]
//        vimeo                               <- map["vimeo"]
//        houseparty                          <- map["houseparty"]
//        calendly                            <- map["calendly"]
//        wechat                              <- map["wechat"]
//        resume                              <- map["resume"]
//        ordering                            <- map["ordering"]
//        social_network                      <- map["social_network"]
//        unique_url                          <- map["unique_url"]
//        affiliate                           <- map["affiliate"]
//        userAffiliateLink                   <- map["userAffiliateLink"]
//        age                                 <- map["age"]
//        productPlanCounter                  <- map["product_plan_counter"]
//        discountCode                        <- map["discount_code"]
//        refCode                             <- map["ref_code"]
//        bluetoothMode                       <- map["bluetooth_mode"]
//    }
//}

//class UserNote: Mappable {
//
//    var id                              : String?
//    var user_id                         : String?
//    var receiver_id                     : String?
//    var title                           : String?
//    var description                     : String?
//    var created_at                      : String?
//    var device_type                     : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        id                              <- map["id"]
//        user_id                         <- map["user_id"]
//        receiver_id                     <- map["receiver_id"]
//        title                           <- map["title"]
//        description                     <- map["description"]
//        created_at                      <- map["created_at"]
//        device_type                     <- map["device_type"]
//    }
//}

//class GetProfileData: Mappable {
//
//    var flag                        : String?
//    var userid                      : String?
//    var profile_data                : [Profile_data]?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        flag                        <- map["flag"]
//        userid                      <- map["userid"]
//        profile_data                <- map["profile_data"]
//    }
//}

//class Profile_data: Mappable {
//
//    var Title                       : String?
//    var Data                        : [Datainfo]?
//    var Totalcount                  : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        Title                       <- map["title"]
//        Data                        <- map["data"]
//        Totalcount                  <- map["count"]
//    }
//}

//class GetProfileDataFromValue: Mappable {
//
//    var flag                        : String?
//    var userid                      : String?
//    var socialid                    : String?
//    var chart_type                  : String?
//    var start_date                  : String?
//    var end_date                    : String?
//    var current_year                : String?
//    var Data                        : [Datainfo]?
//    var Clicks                      : Int?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        flag                        <- map["flag"]
//        userid                      <- map["userid"]
//        socialid                    <- map["socialid"]
//        chart_type                  <- map["chart_type"]
//        start_date                  <- map["start_date"]
//        end_date                    <- map["end_date"]
//        current_year                <- map["current_year"]
//        Data                        <- map["chart_data"]
//        Clicks                      <- map["totalclicks"]
//    }
//}

//class Datainfo: Mappable {
//
//    var data                        : String?
//    var value                       : String?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        data                        <- map["gender_type"]
//        data                        <- map["date"]
//        value                       <- map["value"]
//    }
//}

//class UserBroadCastData: Mappable {
//
//    var broadcastType               : String?
//    var data                        : EventData?
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        broadcastType               <- map["broadcastType"]
//        data                        <- map["data"]
//    }
//}

//class InteractionUserHistory: Mappable {
//
//    var id                          : String?
//    var receiver_id                 : String?
//    var fullName                    : String?
//    var userName                    : String?
//    var device_scan_type            : String?
//    var dt_created                  : String?
//    var isSelected                  : Bool = false
//    //Temp - Hiloni
//    var lat                         : Double?
//    var long                        : Double?
//
//    var duration                    : String?
//    var blueSocialToken             : String?
//    var profileURL                  : String?
//
//
//    required init?(map: Map) {}
//
//    func mapping(map: Map) {
//
//        id                          <- map["id"]
//        receiver_id                 <- map["receiver_id"]
//        fullName                    <- map["fullname"]
//        userName                    <- map["username"]
//        device_scan_type            <- map["device_scan_type"]
//        dt_created                  <- map["dt_created"]
//        lat                         <- map["lat"]
//        long                        <- map["lng"]
//        duration                    <- map["duration"]
//        blueSocialToken             <- map["bst"]
//        profileURL                  <- map["profile_url"]
//    }
//}
