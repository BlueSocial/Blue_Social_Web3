//
//  ReactNativeViewController.swift
//  Blue
//
//  Created by Ethan Santos on 6/20/24.
//  Copyright © 2024 Bluepixel Technologies. All rights reserved.
//

import Foundation
import UIKit
import React

class ReactNativeViewController: UIViewController {
    var initialProperties: [String: Any]?
    var bridge: RCTBridge?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let bridge = self.bridge else {
            print("RCTBridge not set")
            return
        }
        
        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: "ConnectWalletButton",
            initialProperties: initialProperties
        )
        
        self.view = rootView
    }
}
