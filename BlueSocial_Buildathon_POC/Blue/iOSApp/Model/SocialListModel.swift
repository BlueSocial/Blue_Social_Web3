//
//  SocialListModel.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class SocialListModel: Mappable {
    
    var social_network              : [Social_Network]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        social_network              <- map["social_network"]
    }
}

class Social_Network: Mappable, NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
    var id                          : String?
    var seq_order                   : String?
    var social_category_title       : String?
    var is_business_category        : String?
    var social_network_list         : [Social_Network_List]?
    var isExpanded                  : Bool = false
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        id                          <- map["id"]
        seq_order                   <- map["seq_order"]
        social_category_title       <- map["social_category_title"]
        is_business_category        <- map["is_business_category"]
        social_network_list         <- map["social_network_list"]
    }
}

class Social_Network_List: Mappable {
    
    var sid                         : String?
    var categoryid                  : String?
    var social_title                : String?
    var social_seq_order            : String?
    var social_app_order            : String?
    var social_place_holder         : String?
    var social_icon                 : String?
    var social_help_input_type      : String?
    var social_name                 : String?
    var social_class                : String?
    var social_input_type           : String?
    var social_hint_type            : String?
    var social_category_title       : String?
    var user_link_id                : String?
    var value                       : String?
    
    var social_isrowExpand          : Bool = false
    var isCustomLink                : String = "false"
    //var ChartData                   : [Datainfo] = [Datainfo]()
    
    var index1: Int = 0
    var index2: Int = 0
    var snCount: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        sid                         <- map["sid"]
        categoryid                  <- map["categoryid"]
        social_title                <- map["social_title"]
        social_seq_order            <- map["social_seq_order"]
        social_app_order            <- map["social_app_order"]
        social_place_holder         <- map["social_place_holder"]
        social_icon                 <- map["social_icon"]
        social_help_input_type      <- map["social_help_input_type"]
        social_name                 <- map["social_name"]
        social_class                <- map["social_class"]
        social_input_type           <- map["social_input_type"]
        social_hint_type            <- map["social_hint_type"]
        social_category_title       <- map["social_category_title"]
        user_link_id                <- map["user_link_id"]
        value                       <- map["value"]
        
        isCustomLink                <- map["isCustomLink"]
    }
}

class SaveNetwork: Mappable {
    
    var app_version : String?
    var category_id : String?
    var category_type_id : String?
    var device_type : String?
    var flag : String?
    var title : String?
    var type : String?
    var userid : String?
    var value : String?
    var link_id : Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        app_version <- map["app_version"]
        category_id <- map["category_id"]
        category_type_id <- map["category_type_id"]
        device_type <- map["device_type"]
        flag <- map["flag"]
        title <- map["title"]
        type <- map["type"]
        userid <- map["userid"]
        value <- map["value"]
        link_id <- map["link_id"]
    }
}
