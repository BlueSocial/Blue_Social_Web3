//
//  WalletInfoBridge.swift
//  Blue
//
//  Created by Ethan Santos on 6/21/24.
//  Copyright © 2024 Bluepixel Technologies. All rights reserved.
//

import Foundation
import React

@objc(WalletInfoBridge)
class WalletInfoBridge: NSObject {

  @objc
  func sendBalance(_ balance: String, usdRate: String, walletAddress: String, link: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
        // Store the balance, USD rate, wallet address, and link in UserDefaults
        UserDefaults.standard.set(balance, forKey: "userBalance")
        UserDefaults.standard.set(usdRate, forKey: "usdRate")
        UserDefaults.standard.set(walletAddress, forKey: "walletAddress")
        UserDefaults.standard.set(link, forKey: "walletLink")
        // Post a notification with the balance information
        NotificationCenter.default.post(name: .balanceUpdated, object: nil, userInfo: ["balance": balance, "usdRate": usdRate, "walletAddress": walletAddress, "link": link])
    }
    print("Balance received in Swift: \(balance), USD Rate: \(usdRate), Wallet Address: \(walletAddress), Link: \(link)")
    resolve("Balance received: \(balance)")
  }

  @objc
  func fetchBalance(completion: @escaping (String, String, String, String) -> Void) {
    // Fetch the balance, USD rate, wallet address, and link from UserDefaults
    let balance = UserDefaults.standard.string(forKey: "userBalance") ?? "0"
    let usdRate = UserDefaults.standard.string(forKey: "usdRate") ?? "0.0"
    let walletAddress = UserDefaults.standard.string(forKey: "walletAddress") ?? ""
    let link = UserDefaults.standard.string(forKey: "walletLink") ?? ""
    completion(balance, usdRate, walletAddress, link)
  }

  @objc static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
