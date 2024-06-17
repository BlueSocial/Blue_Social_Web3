//
//  CustomMapAnnotation.swift
//  Blue
//
//  Created by Blue.

import Foundation
import MapKit

class CustomMapAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D, image: UIImage?) {
        self.coordinate = coordinate
        self.image = image
        super.init()
    }
}
