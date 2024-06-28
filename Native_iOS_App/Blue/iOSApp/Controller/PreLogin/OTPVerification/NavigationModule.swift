//
//  NavigationModule.swift
//  Blue
//
//  Created by Ethan Santos on 6/20/24.
//  Copyright © 2024 Bluepixel Technologies. All rights reserved.
//

import Foundation
import React

@objc(NavigationModule)
class NavigationModule: NSObject {
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc
  func goBack() {
    print("goBack method called in NavigationModule")
    DispatchQueue.main.async {
      if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
        self.dismissTopMostViewController(controller: rootViewController)
      }
    }
  }

  @objc
  func navigateToTourPage() {
    print("navigateToTourPage method called in NavigationModule")
    DispatchQueue.main.async {
      if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
        self.navigateToTourPageFromTopMostViewController(controller: rootViewController)
      }
    }
  }

    private func dismissTopMostViewController(controller: UIViewController) {
        if let presented = controller.presentedViewController {
          dismissTopMostViewController(controller: presented)
        } else if let navigationController = controller as? UINavigationController {
          navigationController.popViewController(animated: true)
        } else if let tabBarController = controller as? UITabBarController {
          if let selected = tabBarController.selectedViewController {
            dismissTopMostViewController(controller: selected)
          }
        } else {
          controller.dismiss(animated: true, completion: nil)
        }
      }

  private func navigateToTourPageFromTopMostViewController(controller: UIViewController) {
    var topController: UIViewController = controller
    while let presentedViewController = topController.presentedViewController {
      topController = presentedViewController
    }
    if let navigationController = topController as? UINavigationController {
      let tourPageMasterVC = TourPageMasterViewController.instantiate(fromAppStoryboard: .Tour)
      tourPageMasterVC.isFromRegister = true
      navigationController.pushViewController(tourPageMasterVC, animated: true)
    } else {
      print("Top controller is not a UINavigationController: \(topController)")
    }
  }
}
