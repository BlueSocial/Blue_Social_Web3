//
//  UITapGestureRecognizer.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }

        let mutableStr = NSMutableAttributedString.init(attributedString: attributedText)
        mutableStr.addAttributes([NSAttributedString.Key.font: label.font!], range: NSRange.init(location: 0, length: attributedText.length))

        // If the label have text alignment. Delete this code if label have a default (left) aligment. Possible to add the attribute in previous adding.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        mutableStr.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))

        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: mutableStr)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        //return NSLocationInRange(indexOfCharacter, targetRange)

        // Check if the tap is within the target range and not at the end of the string
        return NSLocationInRange(indexOfCharacter, targetRange) && indexOfCharacter < attributedText.length
    }
    
//    // This is also working:
//    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
//        guard let attributedText = label.attributedText else { return false }
//
//        let layoutManager = NSLayoutManager()
//        let textContainer = NSTextContainer(size: label.bounds.size)
//
//        layoutManager.addTextContainer(textContainer)
//        textContainer.lineFragmentPadding = 0.0
//        textContainer.lineBreakMode = label.lineBreakMode
//        textContainer.maximumNumberOfLines = label.numberOfLines
//
//        let textStorage = NSTextStorage(attributedString: attributedText)
//        textStorage.addLayoutManager(layoutManager)
//
//        let location = self.location(in: label)
//        let textOffset = CGPoint(x: 0, y: (label.bounds.height - textContainer.size.height) * 0.5)
//        let textPoint = CGPoint(x: location.x, y: location.y - textOffset.y)
//
//        let charIndex = layoutManager.characterIndex(for: textPoint, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//
//        return NSLocationInRange(charIndex, targetRange)
//    }
}
