//
//  CustomImage.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit


@IBDesignable
class CustomImage: UIImageView {
    
    @IBInspectable var topLeftRightCornerRadius: CGFloat = 0.0
    
    @IBInspectable var IsRound: Bool = false {
        didSet {
            if IsRound {
                layer.cornerRadius = (layer.frame.size.width + layer.frame.size.height) / 4
            }
        }
    }
    
    @IBInspectable var BordeColor: UIColor = UIColor.black {
        didSet {
            layer.borderColor = BordeColor.cgColor
        }
    }
    
    @IBInspectable var BordeHeight: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = BordeHeight
        }
    }
    
    @IBInspectable var CornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = CornerRadius
            //layer.masksToBounds = true
        }
    }
    
    @IBInspectable var ShadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = ShadowColor.cgColor
        }
    }
    
    @IBInspectable var ShadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = ShadowRadius
            layer.masksToBounds = false
        }
    }
    
    @IBInspectable var ShadowOpacity: CGFloat = 0.0 {
        didSet {
            layer.shadowOpacity = Float(ShadowOpacity)
        }
    }
    
    @IBInspectable var ShadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            layer.shadowOffset = ShadowOffset
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if IsRound {
            layer.cornerRadius = (layer.frame.size.width + layer.frame.size.height) / 4
        }
        
        if topLeftRightCornerRadius > 0.0 {            
            roundCorners(corners: [.topLeft, .topRight], radius: topLeftRightCornerRadius)
        }
    }
    
    fileprivate func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
