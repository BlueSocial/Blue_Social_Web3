//
//  Notification.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension Notification.Name {
    
    static let didDynamicDeepLink               = Notification.Name(rawValue: "didDynamicDeepLink")
    static let businessCardUser                 = Notification.Name(rawValue: "businessCardUser")
    static let tourOneScreen                    = Notification.Name("tourOneScreen")
    static let tourTwoScreen                    = Notification.Name("tourTwoScreen")
    static let tourThirdScreen                  = Notification.Name("tourThirdScreen")
    //static let tourFourScreen                 = Notification.Name("tourFourScreen")
    //static let tourFiveScreen                 = Notification.Name("tourFiveScreen")
    static let bleOnOff                         = Notification.Name("bleOnOff")
    static let bluetoothDisconnect              = Notification.Name("bluetoothDisconnect")
    static let nearByOn                         = Notification.Name("NearByOn")
    static let setImage                         = Notification.Name("SetImage")
    static let waitingForNearByClose            = Notification.Name("WaitingForNearByClose")
}
