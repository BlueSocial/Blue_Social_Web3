//
//  UniversityDetails.swift
//  Blue
//
//  Created by Blue.

import Foundation
import ObjectMapper

struct UniversityDetails : Mappable {
    
    var id : String?
    var university_name : String?
    var student_population : String?
    var tipping_point : String?
    var email_ext : String?
    var email_example : String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        id <- map["id"]
        university_name <- map["university_name"]
        student_population <- map["student_population"]
        tipping_point <- map["tipping_point"]
        email_ext <- map["email_ext"]
        email_example <- map["email_example"]
    }
}
