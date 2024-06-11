//
//  InterestTopic.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

struct InterestTopic: Codable {
    
    var imageName: String
    var topic: String
    var isSelected: Bool
    
    mutating func toggleSelection() {
        isSelected = !isSelected
    }
}

struct PhotoModel {
    
    var imageName: String
    var image: UIImage
    var isSelected: Bool
    
    mutating func toggleSelection() {
        isSelected = !isSelected
    }
}
