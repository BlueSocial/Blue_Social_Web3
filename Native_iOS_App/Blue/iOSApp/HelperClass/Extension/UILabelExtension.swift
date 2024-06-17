//
//  UILabel.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension UILabel {
    
    func setupAttributedTextOFLabelForThreeString(text: String, textUnit: String, textColor: UIColor, textUnitColor: UIColor, suffixString: String) {
        
        let myAttribute = [NSAttributedString.Key.foregroundColor: textColor]
        let attrString = NSMutableAttributedString(string: text, attributes: myAttribute)
        let myAttributedTitle = NSMutableAttributedString(string: textUnit, attributes: [.foregroundColor: textUnitColor])
        attrString.append(myAttributedTitle)
        let myAttributedTitle1 = NSMutableAttributedString(string: suffixString, attributes: [.foregroundColor: textColor])
        attrString.append(myAttributedTitle1)
        self.attributedText =  attrString
    }
    
    func setUpAttributedWithDifferentColorAndFont(text: String, textUnit: String, textcolor: UIColor, textUnitColor: UIColor, textFont: UIFont, textUnitFont: UIFont) {
        
        let myAttribute = [NSAttributedString.Key.foregroundColor: textcolor,
                           NSAttributedString.Key.font: textFont]
        let attrString = NSMutableAttributedString(string: text, attributes: myAttribute)
        let myAttributedTitle = NSMutableAttributedString(string: textUnit,
                                                          attributes: [.foregroundColor: textUnitColor,
                                                                       NSAttributedString.Key.font: textUnitFont])
        attrString.append(myAttributedTitle)
        self.attributedText = attrString
    }
    
    func twoPartWithDifferentColorAndFont(
        partOneString: String = "",
        partOneFont: UIFont = UIFont.systemFont(ofSize: 12),
        partOneColor: UIColor = UIColor.black,
        
        partTwoString: String = "",
        partTwoFont: UIFont = UIFont.systemFont(ofSize: 12),
        partTwoColor: UIColor = UIColor.black
    ) {
        let partOneAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: partOneColor,
            .font: partOneFont
        ]
        
        let attrString = NSMutableAttributedString(string: partOneString, attributes: partOneAttributes)
        
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: partTwoColor,
            .font: partTwoFont
        ]
        
        let attributedPartTwo = NSMutableAttributedString(string: partTwoString, attributes: partTwoAttributes)
        attrString.append(attributedPartTwo)
        
        self.attributedText = attrString
    }
    
    func threePartWithDifferentColorAndFont(
        partOneString: String = "",
        partOneFont: UIFont = UIFont.systemFont(ofSize: 12),
        partOneColor: UIColor = UIColor.black,
        
        partTwoString: String = "",
        partTwoFont: UIFont = UIFont.systemFont(ofSize: 12),
        partTwoColor: UIColor = UIColor.black,
        
        partThreeString: String = "",
        partThreeFont: UIFont = UIFont.systemFont(ofSize: 12),
        partThreeColor: UIColor = UIColor.black
    ) {
        let partOneAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: partOneColor,
            .font: partOneFont
        ]
        
        let attrString = NSMutableAttributedString(string: partOneString, attributes: partOneAttributes)
        
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: partTwoColor,
            .font: partTwoFont
        ]
        
        let attributedPartTwo = NSMutableAttributedString(string: partTwoString, attributes: partTwoAttributes)
        attrString.append(attributedPartTwo)
        
        let partThreeAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: partThreeColor,
            .font: partThreeFont
        ]
        
        let attributedPartThree = NSMutableAttributedString(string: partThreeString, attributes: partThreeAttributes)
        attrString.append(attributedPartThree)
        
        self.attributedText = attrString
    }

    /*
     
     self.lblMsg.text = "You sent \(self.amount) tokens to \(self.receiverName)"
     
     let attributedText = NSMutableAttributedString(string: self.lblMsg.text ?? "")
     attributedText.setColor(UIColor.appGray_98A2B1(), forText: "You sent")
     attributedText.setColor(UIColor.appGray_98A2B1(), forText: " to ")
     
     self.lblMsg.attributedText = attributedText
     
     */

}
