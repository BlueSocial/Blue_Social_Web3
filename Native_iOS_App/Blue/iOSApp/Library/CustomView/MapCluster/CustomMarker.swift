//
//  CustomMarker.swift
//  Blue
//
//  Created by Blue.

import Foundation
import GoogleMapsUtils

class CustomMarker: NSObject, GMUClusterItem {
    
    var position: CLLocationCoordinate2D
    var arrDevice: [DeviceScanHistory]
    
    init(position: CLLocationCoordinate2D, arrDevice: [DeviceScanHistory]) {
        self.position = position
        self.arrDevice = arrDevice
    }
}
