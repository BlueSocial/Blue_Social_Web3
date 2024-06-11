//
//  AppPurchaseFeature.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class AppPurchaseFeature: Mappable {
    
    var id                                  : String?
    var name                                : String?
    var amount                              : String?
    var featureList                         : [FeatureList]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        id                                  <- map["id"]
        name                                <- map["name"]
        amount                              <- map["amount"]
        featureList                         <- map["featureList"]
    }
}

class FeatureList: Mappable {
    
    var title                               : String?
    var subtitle                            : String?
    var description                         : String?
    var IsExpand                            : Bool = false
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        title                               <- map["title"]
        subtitle                            <- map["subtitle"]
        description                         <- map["description"]
    }
}
