//
//  Beacon.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class TemplateData : Mappable {
    
    required init?(map: Map) {}
    
    var buttonText                  : String?
    var buttonUrl                   : String?
    var image                       : String?
    var name                        : String?
    var notifyDescription           : String?
    var notifyTitle                 : String?
    var price                       : String?
    
    
    func mapping(map: Map) {
        
        buttonText                  <- map["button_text"]
        buttonUrl                   <- map["button_url"]
        image                       <- map["image"]
        name                        <- map["name"]
        notifyDescription           <- map["notify_description"]
        notifyTitle                 <- map["notify_title"]
        price                       <- map["price"]
    }
}
