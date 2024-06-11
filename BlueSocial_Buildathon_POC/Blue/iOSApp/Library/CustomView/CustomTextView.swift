//
//  CustomTextView.swift
//  Blue
//
//  Created by Blue.

import UIKit


extension UITextView {
    
    @IBInspectable var CornerRadius: CGFloat  {
        get {
            return layer.cornerRadius
        }
        set {
            return layer.cornerRadius  = newValue
        }
    }
}

@IBDesignable
class CustomTextView: UITextView,UITextViewDelegate{

    @IBInspectable var BordeHeight: CGFloat = 0.0 {
        didSet{
            layer.borderWidth = BordeHeight
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0.0 {
        didSet {
            textContainerInset.left = leftPadding
        }
    }
    
    @IBInspectable var rightPadding: CGFloat = 0.0 {
        didSet {
            textContainerInset.right = rightPadding
        }
    }
    
    @IBInspectable var BordeColor: UIColor = UIColor.black {
           didSet{
               layer.borderColor = BordeColor.cgColor
           }
    }
    
    @IBInspectable var placeHolderColor: UIColor = .lightGray {
        didSet{
           self.textColor = placeHolderColor
        }
    }
    
    @IBInspectable var placeholder : String = "" {
        
        didSet {
            self.delegate = self
            self.text = placeholder
        }
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.text = placeholder
            self.textColor = placeHolderColor
            self.resignFirstResponder()
        } else {
            
            if self.textColor == placeHolderColor {
                self.text = ""
            }
             self.tintColor = .blue
             self.textColor = UIColor.black
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.text = placeholder
            self.textColor = placeHolderColor

        } else {
            
            if self.textColor == placeHolderColor {
                self.text = ""
            }
            self.becomeFirstResponder()
            self.textColor = UIColor.black
        }
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
        self.delegate = self
        
        if #available(iOS 13.0, *) {
            self.traitCollection.performAsCurrent {
                layer.borderColor = BordeColor.cgColor
            }
        }
    }
    
    
}
