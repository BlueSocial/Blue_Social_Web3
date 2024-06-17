//
//  CustomLabel.swift
//  Blue
//
//  Created by Blue.

import UIKit

@IBDesignable
class CustomLabel: UILabel {
    
    @IBInspectable var IsRound: Bool = false {
        didSet{
            if IsRound {
                layer.cornerRadius = (layer.frame.size.width + layer.frame.size.height) / 4
                //layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable var BordeHeight: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = BordeHeight
        }
    }
    
    @IBInspectable var marktxtColor: UIColor = .clear {
        
        didSet {
            self.textColor = textColor
        }
    }
    @IBInspectable var CornerRadius: CGFloat = 0{
           
           didSet {
            self.layer.cornerRadius = CornerRadius
           }
       }
    
    @IBInspectable var markText: String = "" {
        
        didSet {
            let strPlaceholder:NSString = self.text! as NSString
            let range = strPlaceholder.range(of: self.markText)
            
            let attributedText =
                NSMutableAttributedString(string: strPlaceholder as String)
            
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: marktxtColor , range: range)
            
            self.attributedText = attributedText
            
            self.layoutIfNeeded()
        }
        
    }
    

    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat = 0.0
    @IBInspectable var rightInset: CGFloat = 0.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
        
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}
