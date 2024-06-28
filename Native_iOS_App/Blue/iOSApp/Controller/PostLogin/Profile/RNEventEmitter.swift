//
//  RNEventEmitter.swift
//  Blue
//
//  Created by Ethan Santos on 6/24/24.
//  Copyright © 2024 Bluepixel Technologies. All rights reserved.
//

import Foundation
import React

@objc(RNEventEmitter)
open class RNEventEmitter: RCTEventEmitter {

    public static var emitter: RNEventEmitter?

    override init() {
        super.init()
        RNEventEmitter.emitter = self
    }

    open override func supportedEvents() -> [String] {
        return ["callBreakTheIce"]
    }

    @objc open override class func requiresMainQueueSetup() -> Bool {
        return false
    }
}

