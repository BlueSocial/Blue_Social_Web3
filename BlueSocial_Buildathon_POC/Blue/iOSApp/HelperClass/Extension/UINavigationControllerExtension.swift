//
//  UINavigationController.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension UINavigationController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
