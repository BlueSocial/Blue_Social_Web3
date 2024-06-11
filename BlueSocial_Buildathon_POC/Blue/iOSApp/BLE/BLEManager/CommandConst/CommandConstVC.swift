//
//  BLEDevice.swift
//  Blue
//
//  Created by Blue.

import UIKit
import Foundation

struct SERVICES {
    // static let SERVICE_UUID = "88E91399-80ED-4943-9BCB-39C532A76023".uppercased()
    static let SERVICE_UUID = "0000AA33-0000-1000-8000-00805F9B34FB".uppercased()
    static let ADVERTISEMENT_DISCOVER_SERVICE_UUID = "000055DD-0000-1000-8000-00805F9B34FB"
}

struct CHAR {
    static let READ_CHAR = "88E91401-80ED-4943-9BCB-39C532A76023".uppercased()
    static let MSG_CHAR = "88E91402-80ED-4943-9BCB-39C532A76023".uppercased()
}

struct COMMAND {
    static let Disconnect = 254
    static let Restart = 255
}

struct REQUEST_TYPE {
    public static let READ = 1
    public static let WRITE = 2
}

struct timeout {
    static let defaultTimeoutInS: TimeInterval = 10
}
