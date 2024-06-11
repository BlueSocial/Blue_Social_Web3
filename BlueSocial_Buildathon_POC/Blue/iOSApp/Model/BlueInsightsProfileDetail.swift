//
//  BlueInsightsProfileDetail.swift
//  Blue
//
//  Created by Blue.

import Foundation
import ObjectMapper

class BlueInsightsProfileDetail: Mappable {
    
    var week                    : ProfileDetail?
    var month                   : ProfileDetail?
    var year                    : ProfileDetail?
    var topLocations            : [TopLocations]?
    var interactionsGender      : [InteractionsGender]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        week                    <- map["week"]
        month                   <- map["month"]
        year                    <- map["year"]
        topLocations            <- map["topLocations"]
        interactionsGender      <- map["interactionsGender"]
    }
}

class ProfileDetail: Mappable {
    
    var interactionCount        : Int?
    var profileVisit            : Int?
    var breakTheIce             : Int?
    var tokensEarned            : Int?
    var linksTapped             : Int?
    var savedContacts           : Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        interactionCount        <- map["interactionCount"]
        profileVisit            <- map["profileVisit"]
        breakTheIce             <- map["breakTheIce"]
        tokensEarned            <- map["tokensEarned"]
        linksTapped             <- map["linksTapped"]
        savedContacts           <- map["savedContacts"]
    }
}

class TopLocations: Mappable {
    
    var city                    : String?
    var code                    : String?
    var tapsCount               : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        city                    <- map["city"]
        code                    <- map["code"]
        tapsCount               <- map["tapsCount"]
    }
}

class InteractionsGender: Mappable {
    
    var gender                  : String?
    var genderCount             : Int?
    var percentage              : Double?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        gender                  <- map["Gender"]
        genderCount             <- map["count"]
        percentage              <- map["percentage"]
    }
}
