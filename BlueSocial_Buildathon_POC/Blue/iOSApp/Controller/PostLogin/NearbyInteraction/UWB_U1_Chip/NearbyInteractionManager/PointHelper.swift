//
//  PointHelper.swift
//  Nearby Interaction
//
//  Created by Harsh on 28.07.2022.
//

import NearbyInteraction

struct Point {
    
    let azimuth: Float?
    let elevation: Float?
    let distance: String?
    var isInUpDirection: Bool = true
    
    init(distance: Float?, direction: simd_float3?) {
        azimuth = direction.map(Point.azimuthValue(_:))
        elevation = direction.map(Point.elevationValue(_:))
        
        if let distance = distance {
            self.distance = String(format: "%0.2f m", distance)
            debugPrint("Distance : ", self.distance ?? "")
            
        } else {
            self.distance = nil
        }
        
        details()
    }
    
    private mutating func details() {
        
        if elevation != nil {
            
            if elevation! < 0 {
                print("down")
                isInUpDirection = false
            } else {
                print("up")
                isInUpDirection = true
            }
            let radian = String(format: "% 3.0f°", elevation!.radiansToDegrees)
            debugPrint("Radians to degree Down Up : ", radian)
        }
        
        if azimuth != nil {
            if azimuth! < 0 {
                print("left")
            } else {
                print("right")
            }
            
            let radian = String(format: "% 3.0f°", azimuth!.radiansToDegrees)
            debugPrint("Radians to degree Left Right : ", radian)
        }
    }
    
    // Provides the azimuth from an argument 3D directional.
    private static func azimuthValue(_ direction: simd_float3) -> Float { asin(direction.x) }
    
    // Provides the elevation from the argument 3D directional.
    private static func elevationValue(_ direction: simd_float3) -> Float { atan2(direction.z, direction.y) + .pi / 2 }
}
