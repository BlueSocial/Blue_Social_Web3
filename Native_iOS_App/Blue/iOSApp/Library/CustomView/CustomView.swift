//
//  CustomView.swift
//  Blue
//
//  Created by Blue.

import UIKit

@IBDesignable
class CustomView: UIView {
    
    @IBInspectable var IsRound: Bool = false {
        didSet {
            if IsRound {
                layer.cornerRadius = (layer.frame.size.width + layer.frame.size.height) / 4
            }
        }
    }
    
    @IBInspectable var IsRoundCorner: Bool = false {
        didSet {
            if IsRoundCorner {
                layer.cornerRadius = (layer.frame.size.height) / 2
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
            //clipsToBounds = true
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
    
    private func updateView() {
        
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
    
    @IBInspectable var topLeftRightCornerRadius: CGFloat = 0.0
    @IBInspectable var bottomLeftRightCornerRadius: CGFloat = 0.0
    
    @IBInspectable var topLeftBottomLeftCornerRadius: CGFloat = 0.0
    @IBInspectable var topRightBottomRightCornerRadius: CGFloat = 0.0
    
    @IBInspectable var topRightCornerRadius: CGFloat = 0.0
    @IBInspectable var topLeftCornerRadius: CGFloat = 0.0
    @IBInspectable var bottomRightCornerRadius: CGFloat = 0.0
    @IBInspectable var bottomLeftCornerRadius: CGFloat = 0.0
    
    @IBInspectable var rotateLeft: CGFloat = 0
    @IBInspectable var rotateRight: CGFloat = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if IsRound {
            layer.cornerRadius = (layer.frame.size.width + layer.frame.size.height) / 4
        }
        
        if IsRoundCorner {
            layer.cornerRadius = (layer.frame.size.height) / 2
        }
        
        if topLeftRightCornerRadius > 0.0 {
            roundCorners(corners: [.topLeft, .topRight], radius: topLeftRightCornerRadius)
        }
        
        if bottomLeftRightCornerRadius > 0.0 {
            roundCorners(corners: [.bottomLeft, .bottomRight], radius: bottomLeftRightCornerRadius)
        }
        
        if topLeftBottomLeftCornerRadius > 0.0 {
            roundCorners(corners: [.topLeft, .bottomLeft], radius: topLeftBottomLeftCornerRadius)
        }
        
        if topRightBottomRightCornerRadius > 0.0 {
            roundCorners(corners: [.topRight, .bottomRight], radius: topRightBottomRightCornerRadius)
        }
        
        if topLeftCornerRadius > 0.0 {
            roundCorners(corners: [.topLeft], radius: topLeftCornerRadius)
        }
        
        if topRightCornerRadius > 0.0 {
            roundCorners(corners: [.topRight], radius: topRightCornerRadius)
        }
        
        if bottomLeftCornerRadius > 0.0 {
            roundCorners(corners: [.bottomLeft], radius: bottomLeftCornerRadius)
        }
        
        if bottomRightCornerRadius > 0.0 {
            roundCorners(corners: [.bottomRight], radius: bottomRightCornerRadius)
        }
        
        if rotateLeft != 0.0 {
            rotateView(self, angle: rotateLeft)
        }
        
        if rotateRight != 0.0 {
            rotateView(self, angle: rotateRight)
        }
    }
    
    fileprivate func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func rotateView(_ view: UIView, angle: CGFloat) {
        //           // Create a rotation transform
        //           let rotationTransform = CGAffineTransform(rotationAngle: angle * .pi / 180.0)
        //
        //           // Apply the rotation transform to the view's layer
        //           view.layer.setAffineTransform(rotationTransform)
        
        // Convert angle to radians
        let radians = angle * .pi / 180.0
        
        // Create a rotation transform
        var transform = CATransform3DMakeRotation(radians, 0, 0, 1)
        
        // Set the anchor point for rotation
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Apply the rotation transform to the view's layer
        view.layer.transform = transform
    }
}
