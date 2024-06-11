//
//  iBeacon.swift
//  Blue
//
//  Created by Blue.

import UIKit
import CoreLocation

class iBeacon: NSObject {
    
    var major                       : NSNumber!
    var minor                       : NSNumber!
    var uuid                        : String!
    var rssis                       : [Int]!
    var avgRssi                     : Int!
    
    init(beacon: CLBeacon) {
        super.init()
        
        uuid                        = beacon.uuid.uuidString
        major                       = beacon.major
        minor                       = beacon.minor
        rssis                       = [beacon.rssi]
        avgRssi                     = beacon.rssi
    }
}
