//
//  CustomButtonManager.swift
//  Blue
//
//  Created by Ethan Santos on 6/16/24.
//  Copyright © 2024 Bluepixel Technologies. All rights reserved.
//

import Foundation
import React

@objc(CustomButtonManager)
class CustomButtonManager: RCTViewManager {
  override func view() -> UIView! {
    return ConnectWalletButton()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}

class ConnectWalletButton: UIView {
  private let button: UIButton = {
    let btn = UIButton(type: .system)
    btn.setTitle("Register", for: .normal)
    btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    return btn
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(button)
    button.frame = self.bounds
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func buttonTapped() {
    print("hi")
  }
}
