//
//  TemplateData.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class Beacon: Mappable {
    
    required init?(map: Map) {}
    
    var isTapSocial                 : Bool = false
    var isBeacon                    : Bool = true
    var alias                       : String?
    var beaconid                    : String?
    var bname                       : String?
    var deleted                     : String?
    var descriptionField            : String?
    var dtCreated                   : String?
    var dtUpdated                   : String?
    var favicon                     : String?
    var id                          : String?
    var isactive                    : String?
    var landingId                   : String?
    var language                    : String?
    var locationReference           : String?
    var macaddress                  : String?
    var major                       : String?
    var message                     : String?
    var minor                       : String?
    var name                        : String?
    var offerUrl                    : String?
    var offerImage                  : String?
    var ruleId                      : String?
    var staticurl                   : String?
    var templateData                : [TemplateData]?
    var templateType                : String?
    var title                       : String?
    var url                         : String?
    var urlOwnership                : Bool?
    var userid                      : String?
    var uuid                        : String?
    var userDetail                  : UserDetail?
    //InviteNotification
    var user_id                     : String?
    var receiver_id                 : String?
    var view_type                   : Int?
    //add from the iBeaconManager Class when we send data to front side every 6 second
    var avgRssi                     : Int!
    var button_title                : String?
    var distanceInMeter             : Double?
    var timeStamp                   : Double = 0.0
    var peripheralUUID              : String?
    
    func mapping(map: Map) {
        
        alias                       <- map["alias"]
        beaconid                    <- map["beaconid"]
        bname                       <- map["bname"]
        deleted                     <- map["deleted"]
        descriptionField            <- map["description"]
        dtCreated                   <- map["dt_created"]
        dtUpdated                   <- map["dt_updated"]
        favicon                     <- map["favicon"]
        id                          <- map["id"]
        isactive                    <- map["isactive"]
        landingId                   <- map["landing_id"]
        language                    <- map["language"]
        locationReference           <- map["location_reference"]
        macaddress                  <- map["macaddress"]
        major                       <- map["major"]
        message                     <- map["message"]
        minor                       <- map["minor"]
        name                        <- map["name"]
        offerUrl                    <- map["offer_url"]
        offerImage                  <- map["offer_img"]
        ruleId                      <- map["rule_id"]
        staticurl                   <- map["staticurl"]
        templateData                <- map["template_data"]
        templateType                <- map["template_type"]
        title                       <- map["title"]
        url                         <- map["url"]
        urlOwnership                <- map["url_ownership"]
        userid                      <- map["userid"]
        uuid                        <- map["uuid"]
        //InviteNotification
        user_id                     <- map["user_id"]
        receiver_id                 <- map["receiver_id"]
        view_type                   <- map["view_type"]
        //Nearby Meassges use key
        isBeacon                    <- map["isBeacon"]
        isTapSocial                 <- map["isTapSocial"]
        button_title                <- map["button_title"]
        peripheralUUID              <- map["peripheral_uuid"]
    }
}
