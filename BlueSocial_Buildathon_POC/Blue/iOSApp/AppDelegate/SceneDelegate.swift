//
//  SceneDelegate.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit
import FirebaseDynamicLinks
//import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        guard let url = userActivity.webpageURL else { return }
        
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
            
            guard let dynamicLink = dynamicLink, let _ = dynamicLink.url else { return }
            //parseDynamicLink(fromURL: url)
            self.handelIncomingDynamicLink(dynamicLink)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let urlContext = URLContexts.first else { return }
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: urlContext.url) {
            guard let _ = dynamicLink.url else { return }
            self.handelIncomingDynamicLink(dynamicLink)
        }
        
        //guard let url = URLContexts.first?.url else { return }
        
        //ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func handelIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        
        if (userDef.value(forKey: APIFlagValue.kLogin) != nil) {
            
            guard let url = dynamicLink.url else { return }
            
            let getslugid  = url.absoluteString.split(separator: "/")
            let _ = String(getslugid.last!)
            
            //NotificationCenter.default.post(name: .didDynamicDeepLink, object: userHashData, userInfo: nil)
        }
    }
}
