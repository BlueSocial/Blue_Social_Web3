//
//  Int.swift
//  Blue
//
//  Created by Blue.

import Foundation

extension Int {
    
    func randomNumber(range: Range<Int>) -> Int {
        let min = range.startIndex
        let max = range.endIndex
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
}
