//
//  Date.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension Date {
    
    static func -(lhs: Date, rhs: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -rhs, to: lhs)!
    }
    
    func add(_ unit: Calendar.Component = .day, value: Int) -> Date? {
        return Calendar.current.date(byAdding: unit, value: value, to: self)
    }
    
    func getDaysInMonth() -> Int {
        let calendar = Calendar.current
        
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
    
    func toString(format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}
