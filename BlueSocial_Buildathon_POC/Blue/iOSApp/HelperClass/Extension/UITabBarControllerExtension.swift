//
//  UITabBarController.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension UITabBarController {
    
//    open override var childForStatusBarStyle: UIViewController? {
//        return selectedViewController
//    }
//    
//    open override var preferredStatusBarStyle: UIStatusBarStyle {
//        
//        var shouldShowLightContent: Bool = false
//        
//        if self.selectedViewController?.isKind(of: UINavigationController.self) ?? false {
//            
//            let nVC = selectedViewController as? UINavigationController
//            
//            for controller in nVC?.viewControllers ?? [] {
//                if controller.isKind(of: DiscoverVC.self) {
//                    shouldShowLightContent = true
//                }
//            }
//        }
//        
//        if (UIApplication.getTopViewController()?.isKind(of: DiscoverVC.self) ?? false) || (UIApplication.getTopViewController()?.isKind(of: ProfileVC.self) ?? false) || (UIApplication.getTopViewController()?.isKind(of: EditProfileVC.self) ?? false) {
//            shouldShowLightContent = true
//        }
//        
//        if shouldShowLightContent {
//            return .lightContent
//        } else {
//            return .darkContent
//        }
//    }
}
