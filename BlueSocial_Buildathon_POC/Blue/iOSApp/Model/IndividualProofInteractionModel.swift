//
//  IndividualProofInteractionModel.swift
//  Blue
//
//  Created by Blue.

import Foundation
import ObjectMapper

class IndividualProofInteractionModel: Mappable {
    
    var id                          : String?
    var receiver_id                 : String?
    var fullName                    : String?
    var firstName                   : String?
    var lastName                    : String?
    var userName                    : String?
    var device_scan_type            : String?
    var dt_created                  : String?
    var lat                         : Double?
    var long                        : Double?
    var bst                         : String?
    var duration                    : String?
    var blueSocialToken             : String?
    var profileURL                  : String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        id                          <- map["id"]
        receiver_id                 <- map["receiver_id"]
        fullName                    <- map["fullname"]
        firstName                   <- map["firstname"]
        lastName                    <- map["lastname"]
        userName                    <- map["username"]
        bst                         <- map["bst"]
        device_scan_type            <- map["device_scan_type"]
        dt_created                  <- map["dt_created"]
        lat                         <- map["lat"]
        long                        <- map["lng"]
        duration                    <- map["duration"]
        blueSocialToken             <- map["bst"]
        profileURL                  <- map["profile_url"]
    }
}
