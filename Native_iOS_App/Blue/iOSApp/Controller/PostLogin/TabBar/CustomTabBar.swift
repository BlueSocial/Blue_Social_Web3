//
//  CustomTabBar.swift
//  Blue
//
//  Created by Blue.

import UIKit

class CustomTabBar: UITabBar {
    
    private var shapeLayer: CALayer?
    private var btnDiscover = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupMiddleButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.btnDiscover.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    }
    
    func enableUserInteraction() {
        
        self.btnDiscover.isUserInteractionEnabled = true
    }
    
    func disableUserInteraction() {
        
        self.btnDiscover.isUserInteractionEnabled = false
    }
    
    func setupMiddleButton() {
        
        self.btnDiscover.frame.size = CGSize(width: 72, height: 72)
        //btnDiscover.backgroundColor = .red
        self.btnDiscover.backgroundColor = .clear
        self.btnDiscover.layer.cornerRadius = 36
        self.btnDiscover.layer.masksToBounds = true
        self.btnDiscover.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        self.btnDiscover.addTarget(self, action: #selector(self.onBtnDiscover), for: .touchUpInside)
        addSubview(self.btnDiscover)
    }
    
    @objc func onBtnDiscover() {
        print("Discover Tapped")
        
        // Check if the root view controller is a UINavigationController
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            // Check if the top view controller of the navigation stack is a UITabBarController
            if let tabBarController = navigationController.topViewController as? UITabBarController {
                // Set the selected index to the desired tab index (2 in your case)
                tabBarController.selectedIndex = 1
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.addShape()
    }
    
    private func addShape() {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        //        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        //shapeLayer.fillColor = #colorLiteral(red: 0.01176470588, green: 0.07058823529, blue: 0.1529411765, alpha: 0.1508318162)
        shapeLayer.fillColor = UIColor.appWhite_E6E8EC().cgColor
        //        shapeLayer.lineWidth = 0.5
        //        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        //        shapeLayer.shadowRadius = 10
        //        shapeLayer.shadowColor = UIColor.gray.cgColor
        //        shapeLayer.shadowOpacity = 0.3
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }
    
    func createPath() -> CGPath {
        
        let radius: CGFloat = 42.0
        var path = UIBezierPath()
        path = type(of: path).init(roundedRect: bounds, cornerRadius: 22.0)
        let centerWidth = self.frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (centerWidth - radius * 2), y: 0))
        path.addArc(withCenter: CGPoint(x: centerWidth, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.close()
        return path.cgPath
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let from = point
        let to = btnDiscover.center
        
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? btnDiscover : super.hitTest(point, with: event)
    }
}

extension CGFloat {
    
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var RadiansToDegrees: CGFloat { return self * 180 / .pi }
}
