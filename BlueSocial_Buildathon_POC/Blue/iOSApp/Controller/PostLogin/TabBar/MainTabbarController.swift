//
//  MainTabbarController.swift
//  Blue
//
//  Created by Blue.

import UIKit

class MainTabbarController: UITabBarController {
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    @IBInspectable var defaultIndex: Int = 1
    internal var isFromRegister: Bool = false
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedIndex = defaultIndex
        delegate = self // Set the delegate to self
    }
}

extension MainTabbarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // This method is called when a tab is selected.
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
            switch index {
                case 0:
                    // Custom action for the first tab
                    print("1: Interactions tab selected")
                    // Perform your custom action here
                case 1:
                    // Custom action for the first tab
                    print("3: Discover tab selected")
                    // Perform your custom action here
                case 2:
                    // Custom action for the first tab
                    print("5: More tab selected")
                    // Perform your custom action here
                    
                    // Add cases for other tabs as needed
                default:
                    break
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // Check the selected index
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
            
            switch index {
                    
                default:
                    // Show the CustomTabBar for other indices
                    tabBar.isHidden = false
                    return true
            }
        }
        return true
    }
}
