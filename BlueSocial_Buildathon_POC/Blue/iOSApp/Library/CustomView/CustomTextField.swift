//
//  CustomTextField.swift
//  Blue
//
//  Created by Blue.

import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
    @IBInspectable var BordeHeight: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = BordeHeight
        }
    }
    
    @IBInspectable var LeftPadding: CGFloat = 0.0 {
        didSet {
            let leftview = UIView(frame: CGRect(x: 0, y: 0, width: Int(LeftPadding), height: Int(frame.size.height)))
            leftView = leftview
            leftViewMode = .always
        }
    }
    
    @IBInspectable var RightPadding: CGFloat = 0.0 {
        didSet {
            let rightview = UIView(frame: CGRect(x: 0, y: 0, width: Int(LeftPadding), height: Int(frame.size.height)))
            rightView = rightview
            rightViewMode = .always
        }
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: placeHolderColor!])
        }
    }
    
    @IBInspectable var CursorColor : UIColor? {
        didSet {
            self.tintColor = CursorColor
        }
    }
    
    @IBInspectable var BordeColor: UIColor = UIColor.black {
        didSet{
            layer.borderColor = BordeColor.cgColor
        }
    }
    
    @IBInspectable var bottomBorderHeight: CGFloat = 0.0
    @IBInspectable var bottomBorderColor: UIColor = .clear
    
    @IBInspectable var topBorderHeight: CGFloat = 0.0
    @IBInspectable var topBorderColor: UIColor = .clear
    
    @IBInspectable var leftBorderHeight: CGFloat = 0.0
    @IBInspectable var leftBorderColor: UIColor = .clear
    
    @IBInspectable var rightBorderHeight: CGFloat = 0.0
    @IBInspectable var rightBorderColor: UIColor = .clear
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        if bottomBorderHeight > 0 {
    
            let label = UILabel()
            label.backgroundColor = bottomBorderColor
//            label.layer.cornerRadius = CornerRadius
            label.frame = CGRect(x: 0, y: self.bounds.size.height - bottomBorderHeight, width: self.bounds.size.width, height: bottomBorderHeight)
            
            addSubview(label)
            
        }
        
        if topBorderHeight > 0 {
            
            let label = UILabel()
            label.backgroundColor = topBorderColor
//            label.layer.cornerRadius = CornerRadius
            label.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: topBorderHeight)
            
            addSubview(label)
            
        }
        
        if leftBorderHeight > 0 {
            
            let label = UILabel()
            label.backgroundColor = leftBorderColor
//            label.layer.cornerRadius = CornerRadius
            label.frame = CGRect(x: 0, y: 0, width: leftBorderHeight, height: bounds.size.height)
            
            addSubview(label)
        }
        
        if rightBorderHeight > 0 {
            
            let label = UILabel()
            label.backgroundColor = rightBorderColor
//            label.layer.cornerRadius = CornerRadius
            label.frame = CGRect(x: bounds.size.width - rightBorderHeight, y: 0, width: rightBorderHeight, height: bounds.size.height)
            
            addSubview(label)
        }
        
        if #available(iOS 13.0, *) {
            self.traitCollection.performAsCurrent {
                layer.borderColor = BordeColor.cgColor
            }
        }
    }
}

class NoCopyPasteTextField: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false // Disable copy and paste
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
