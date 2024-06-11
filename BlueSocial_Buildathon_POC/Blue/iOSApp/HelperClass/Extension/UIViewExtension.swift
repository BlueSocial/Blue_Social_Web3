//
//  UIView.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable
    /// Border width of view; also inspectable from Storyboard.
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var viewCornerRadius: CGFloat {
        get {
            return self.viewCornerRadius
        } set {
            DispatchQueue.main.async {
                self.layer.cornerRadius = newValue
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var isLaunchScreen: Bool {
        get {
            return true
        } set {
            DispatchQueue.main.async {
//                self.applyGradient(colours: [UIColor(red: 0.616, green: 0.443, blue: 0.807, alpha: 1.0), UIColor(red: 0.0, green: 0.509, blue: 0.992, alpha: 1.0)])
            }
        }
    }
    
    //Set Gradient Color for Premium user
    @discardableResult
    func applyGradient(colours: [UIColor], startPoint: CGPoint = CGPoint(x: 1, y: 0), endPoint: CGPoint = CGPoint(x: 0, y: 1)) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil, startPoint: startPoint, endPoint: endPoint)
    }
    
    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?, startPoint: CGPoint, endPoint: CGPoint) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.name = "backgroudLayer"
        gradient.frame = self.bounds
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    func dropShadowWithCornerRadius(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true, cornerRadius : CGFloat = 0 ){
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
    }
    
    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Page Master -
    // ----------------------------------------------------------
    func fitToSelf(childView: UIView) {
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["childView": childView]
        
        self.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat : "H:|[childView]|",
                options          : [],
                metrics          : nil,
                views            : bindings
            ))
        
        self.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat : "V:|[childView]|",
                options          : [],
                metrics          : nil,
                views            : bindings
            ))
    }
    
    func shake(for duration: TimeInterval = 0.5, withTranslation translation: CGFloat = 10) {
        
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.3) {
            self.transform = CGAffineTransform(translationX: translation, y: 0)
        }
        
        propertyAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.2)
        
        propertyAnimator.startAnimation()
    }
    
    func animateTo(frame: CGRect, withDuration duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        
        guard let _ = superview else { return }
        
        let xScale = frame.size.width / self.frame.size.width
        let yScale = frame.size.height / self.frame.size.height
        let x = frame.origin.x + (self.frame.width * xScale) * self.layer.anchorPoint.x
        let y = frame.origin.y + (self.frame.height * yScale) * self.layer.anchorPoint.y
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            self.layer.position = CGPoint(x: x, y: y)
            self.transform = self.transform.scaledBy(x: xScale, y: yScale)
        }, completion: completion)
    }
}
