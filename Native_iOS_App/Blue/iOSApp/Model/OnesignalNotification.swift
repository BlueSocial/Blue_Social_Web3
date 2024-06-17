//
//  OnesignalNotification.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class OnesignalNotification: Mappable {
    
    var aps                             : Ap?
    var custom                          : Custom?
    var att                             : Att?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        aps                             <- map["aps"]
        custom                          <- map["custom"]
        att                             <- map["att"]
    }
}

class Att : Mappable {
    
    var id                              : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        id                              <- map["id"]
    }
}

class Custom : Mappable {
    
    var i                               : String?
    var u                               : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        i                               <- map["i"]
        u                               <- map["u"]
    }
}

class Ap : Mappable {
    
    var alert                           : Alert?
    var mutablecontent                  : Int?
    var sound                           : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        alert                           <- map["alert"]
        mutablecontent                  <- map["mutable-content"]
        sound                           <- map["sound"]
    }
}


class Alert : Mappable {
    
    var body                            : String?
    var subtitle                        : String?
    var title                           : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        body                            <- map["body"]
        subtitle                        <- map["subtitle"]
        title                           <- map["title"]
    }
}
