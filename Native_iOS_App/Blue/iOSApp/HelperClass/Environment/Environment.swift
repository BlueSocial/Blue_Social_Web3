//
//  Environment.swift
//  Blue
//
//  Created by Blue.

import Foundation

let BaseURL = Environment.APIBasePath()

class Environment {
    
    class func APIBasePath() -> String {
        
#if Staging
        return "http://52.25.225.196/api/"
        // return "http://new.anasource.com/team12/team5/blue_web/api/"
#else
        return "https://www.profiles.blue/api/"
#endif
        
    }
}
