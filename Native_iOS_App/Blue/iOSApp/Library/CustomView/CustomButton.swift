//
//  CustomButton.swift
//  Blue
//
//  Created by Blue.

import UIKit

@IBDesignable
class CustomButton: UIButton {
    
    @IBInspectable var IsRound: Bool = false {
        didSet{
            if IsRound {
                layer.cornerRadius = (layer.frame.size.width + layer.frame.size.height) / 4
            }
        }
    }
    
    @IBInspectable var BordeHeight: CGFloat = 0.0 {
        didSet {
            
            layer.borderWidth = BordeHeight
        }
    }
    
    @IBInspectable var BordeColor: UIColor = .clear {
        didSet {
            layer.borderColor = BordeColor.cgColor
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
        }
    }
    
    @IBInspectable var ShadowOpacity: CGFloat = 0.0 {
        didSet {
            layer.shadowOpacity = Float(ShadowOpacity)
        }
    }
    @IBInspectable var ShadowOffset : CGSize = CGSize(width: 0, height: 0) {
        didSet {
            layer.shadowOffset = ShadowOffset
        }
    }
    
    @IBInspectable var firstGradientColor: UIColor? = nil {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var secondGradientColor: UIColor? = nil {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var isHorizontal: Bool = false {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        
        if firstGradientColor != nil, secondGradientColor != nil {
            let layer = self.layer as! CAGradientLayer
            layer.colors = [firstGradientColor!, secondGradientColor!].map{$0.cgColor}
            if (self.isHorizontal) {
                layer.startPoint = CGPoint(x: 0, y: 0.5)
                layer.endPoint = CGPoint (x: 1, y: 0.5)
                
            } else {
                layer.startPoint = CGPoint(x: 0.5, y: 0)
                layer.endPoint = CGPoint (x: 0.5, y: 1)
            }
        }
    }
}
