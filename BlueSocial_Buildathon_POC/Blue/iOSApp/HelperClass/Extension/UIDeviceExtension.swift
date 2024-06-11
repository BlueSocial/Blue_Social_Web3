//
//  UIDevice.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

extension UIDevice {
    
    class var isSimulator: Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
}
