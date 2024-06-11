//
//  UIColor.swift
//  Blue
//
//  Created by Blue.

import UIKit

extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
    }
    
    static func appBlack_031227() -> UIColor {
        return UIColor(hexString: "#031227")
    }
    
    static func appBlack_031227_Opacity_10() -> UIColor {
        return UIColor(hexString: "#031227").withAlphaComponent(0.1)
    }
    
    static func appBlack_031227_Opacity_20() -> UIColor {
        return UIColor(hexString: "#031227").withAlphaComponent(0.2)
    }
    
    static func appBlack_031227_Opacity_60() -> UIColor {
        return UIColor(hexString: "#031227").withAlphaComponent(0.6)
    }
    
    static func appBlue_0066FF() -> UIColor {
        return UIColor(hexString: "#0066FF")
    }
    
    static func appBlue_0083FD() -> UIColor {
        return UIColor(hexString: "#0083FD")
    }
    
    static func appGray_98A2B1() -> UIColor {
        return UIColor(hexString: "#98A2B1")
    }
    
    static func appGray_F2F3F4() -> UIColor {
        return UIColor(hexString: "#F2F3F4")
    }
    
    static func appGray_DADADA() -> UIColor {
        return UIColor(hexString: "#DADADA")
    }
    
    static func appGray_979797() -> UIColor {
        return UIColor(hexString: "#979797")
    }
    
    static func appRed_E13C3C() -> UIColor {
        return UIColor(hexString: "#E13C3C")
    }
    
    static func appRed_FD0000() -> UIColor {
        return UIColor(hexString: "#FD0000")
    }
    
    static func appBlack_000000() -> UIColor {
        return UIColor(hexString: "#000000")
    }
    
    static func appWhite_FFFFFF() -> UIColor {
        return UIColor(hexString: "#FFFFFF")
    }
    
    static func appWhite_FFFFFF_Opacity_16() -> UIColor {
        return UIColor(hexString: "#FFFFFF").withAlphaComponent(0.16)
    }
    
    static func appWhite_DFECFF() -> UIColor {
        return UIColor(hexString: "#DFECFF")
    }
    
    static func appWhite_E6E8EC() -> UIColor {
        return UIColor(hexString: "#E6E8EC")
    }
    
    static func appBlueGradient1_495AFF() -> UIColor {
        return UIColor(hexString: "#495AFF")
    }
    
    static func appBlueGradient2_0ACFFE() -> UIColor {
        return UIColor(hexString: "#0ACFFE")
    }
    
    static func appBlueGradient3_431CB8() -> UIColor {
        return UIColor(hexString: "#431CB8")
    }
    
    static func appBlueGradient4_182EFF() -> UIColor {
        return UIColor(hexString: "#182EFF")
    }
    
    static func appBlueGradient5_00C0EE() -> UIColor {
        return UIColor(hexString: "#00C0EE")
    }
    
    static func appGreen_14CD14() -> UIColor {
        return UIColor(hexString: "#14CD14")
    }
    
    static func appGreen_01D02F() -> UIColor {
        return UIColor(hexString: "#01D02F")
    }
}
