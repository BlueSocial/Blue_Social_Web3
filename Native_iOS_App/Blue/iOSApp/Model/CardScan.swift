//
//  CardScan.swift
//  Blue
//
//  Created by Blue.

import Foundation
import ObjectMapper

struct CardScan: Mappable {
    
    var language                : String?
    var id                      : String?
    var firstName               : String?
    var lastName                : String?
    var middleName              : String?
    var emails                  : [CardScanEmails]?
    var phones                  : [CardScanPhones]?
    var jobs                    : [CardScanJobs]?
    var websites                : [CardScanWebsites]?
    var notes                   : String?
    var addresses               : [CardScanAddresses]?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        language                <- map["language"]
        id                      <- map["id"]
        firstName               <- map["firstName"]
        lastName                <- map["lastName"]
        middleName              <- map["middleName"]
        emails                  <- map["emails"]
        phones                  <- map["phones"]
        jobs                    <- map["jobs"]
        websites                <- map["websites"]
        notes                   <- map["notes"]
        addresses               <- map["addresses"]
    }
}

struct CardScanEmails: Mappable {
    
    var address                 : String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        address                 <- map["address"]
    }
}

struct CardScanJobs: Mappable {
    
    var company                 : String?
    var title                   : String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        company                 <- map["company"]
        title                   <- map["title"]
    }
}

struct CardScanPhones: Mappable {
    
    var number                  : String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        number                  <- map["number"]
    }
}

struct CardScanWebsites: Mappable {
    
    var url                     : String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        url                     <- map["url"]
    }
}

struct CardScanAddresses: Mappable {
    
    var fullAddress             : String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        fullAddress             <- map["fullAddress"]
    }
}
