//
//  AppStoryboard.swift
//  Blue
//
//  Created by Blue.


import UIKit

/// Add Storyboard names if added new
enum AppStoryboard: String {
    
    case Login, Main, Discover, Tour, NearbyInteraction, BlueProUserProfile, Referral
    
    var instance: UIStoryboard {
        
        let name = UIDevice.current.userInterfaceIdiom == .pad ? "\(self.rawValue)_iPad" : self.rawValue
        return UIStoryboard(name: name, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type, function : String = #function, line : Int = #line, file : String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard = .Main) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
}
