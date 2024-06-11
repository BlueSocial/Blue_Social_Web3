//
//  InsightProfileChartDetail.swift
//  Blue
//
//  Created by Blue.

import Foundation
import ObjectMapper

class InsightProfileChartDetail: Mappable {
    
    var type : String?
    var x : [String]?
    var interactions : [String]?
    var profileVisit : [String]?
    var breakTheIce : [String]?
    var tokensEarned : [String]?
    var savedContacts : [String]?
    var linksTapped : [String]?
    var interactionsMax : String?
    var profileVisitMax : String?
    var breakTheIceMax : String?
    var tokensEarnedMax : String?
    var savedContactsMax : String?
    var linksTappedMax : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        type <- map["type"]
        x <- map["x"]
        interactions <- map["interactions"]
        profileVisit <- map["profileVisit"]
        breakTheIce <- map["breakTheIce"]
        tokensEarned <- map["tokensEarned"]
        savedContacts <- map["savedContacts"]
        linksTapped <- map["linksTapped"]
        interactionsMax <- map["interactionsMax"]
        profileVisitMax <- map["profileVisitMax"]
        breakTheIceMax <- map["breakTheIceMax"]
        tokensEarnedMax <- map["tokensEarnedMax"]
        savedContactsMax <- map["savedContactsMax"]
        linksTappedMax <- map["linksTappedMax"]
    }
}
