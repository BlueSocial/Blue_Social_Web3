//
//  String.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension String {
    
//    var containsEmoji: Bool {
//        let emojiPattern = UnicodeScalar(0x1F600)...UnicodeScalar(0x1F64F)
//        return self.unicodeScalars.contains { scalar in
//            emojiPattern.contains(scalar)
//        }
//    }
    
    var containsEmoji: Bool {
        
        for character in self {
            let scalar = character.unicodeScalars.first!
            // Check if the scalar is an emoji, not a digit, and not emoji presentation or modifier
            if scalar.properties.isEmoji && !scalar.properties.isEmojiPresentation && !scalar.properties.isEmojiModifier && !character.isWholeNumber {
                return true
            }
        }
        return false
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isContainCharSet() -> Bool {
        let letters = NSCharacterSet.letters
        let range = self.rangeOfCharacter(from: letters)
        
        // range will be nil if no letters is found
        if let test = range {
            return true
        } else {
            return false
        }
    }
    
    func capitalizingFirstLetter() -> String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func isContainSpecialCharSet() -> Bool {
        
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
        
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        } else {
            return false
        }
    }
    
    func isPhoneNumber() -> Bool {
        guard !self.isEmpty else { return false }
        return !self.contains { Int(String($0)) == nil}
    }
    
    func isValidPhoneNumber() -> Bool {
        //let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"
        let regEx = "[0-9]{6,14}[0-9]$"
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: self)
    }
    
    func trime() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Trim leading spaces
    func trimingLeadingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) }) else {
            return self
        }
        
        return String(self[index...])
    }
    
    // let trimmedStr = "  Hello World ".trimingLeadingSpaces() // returns "Hello World "
    
    // Trim trailing spaces
    func trimingTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) }) else {
            return self
        }
        
        return String(self[...index])
    }
    
    // let trimmedStr = "  Hello World ".trimingTrailingSpaces() // returns "  Hello World"
    
    // Trim leading and trailing spaces
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
    
    // let trimmedStr = "  Hello World ".trimmingLeadingAndTrailingSpaces() // returns "Hello World"
    
    // Trim all spaces
    func trimmingAllSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return components(separatedBy: characterSet).joined()
    }
    
    // let trimmedStr = "  Hello World ".trimmingAllSpaces() // returns "HelloWorld"
    
    func isValidurl() -> Bool {
        
        // create NSURL instance
        if let url = URL(string: self) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url)
        } else {
            return false
        }
    }
    
    func appendLineToURL(fileURL: URL) throws {
        try (self).appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
    
    func firstCharacterUpperCase() -> String? {
        guard !isEmpty else { return nil }
        let lowerCasedString = self.lowercased()
        return lowerCasedString.replacingCharacters(in: lowerCasedString.startIndex...lowerCasedString.startIndex, with: String(lowerCasedString[lowerCasedString.startIndex]).uppercased())
    }
    
    func toDate(format: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = format
        //df.timeZone = TimeZone.utc
        return df.date(from: self)
    }
}

/*
 
 extension String {
 enum TrimmingOptions {
 case all
 case leading
 case trailing
 case leadingAndTrailing
 }
 
 func trimming(spaces: TrimmingOptions, using characterSet: CharacterSet = .whitespacesAndNewlines) ->  String {
 switch spaces {
 case .all: return trimmingAllSpaces(using: characterSet)
 case .leading: return trimingLeadingSpaces(using: characterSet)
 case .trailing: return trimingTrailingSpaces(using: characterSet)
 case .leadingAndTrailing:  return trimmingLeadingAndTrailingSpaces(using: characterSet)
 }
 }
 
 private func trimingLeadingSpaces(using characterSet: CharacterSet) -> String {
 guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) }) else {
 return self
 }
 
 return String(self[index...])
 }
 
 private func trimingTrailingSpaces(using characterSet: CharacterSet) -> String {
 guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) }) else {
 return self
 }
 
 return String(self[...index])
 }
 
 private func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet) -> String {
 return trimmingCharacters(in: characterSet)
 }
 
 private func trimmingAllSpaces(using characterSet: CharacterSet) -> String {
 return components(separatedBy: characterSet).joined()
 }
 }
 And this is how to use it:
 
 let string = "  Hello World "
 
 let withoutLeadingSpaces = string.trimming(spaces: .leading) // "Hello World "
 let withoutTrailingSpaces = string.trimming(spaces: .trailing) // "   Hello World"
 let withoutLeadingAndTrailingSpaces = string.trimming(spaces: .leadingAndTrailing) // "Hello World"
 let withoutAllSpaces = string.trimming(spaces: .all) // "HelloWorld"
 
 */
