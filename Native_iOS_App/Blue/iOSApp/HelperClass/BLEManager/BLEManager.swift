//
//  BLEManager.swift
//  Blue 
//
//  Created by Blue on 03/08/2020.
//  Copyright © 2020 Blue Social. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications

let blemanager = BLEManager()

public class BLEManager: NSObject {
    
    // ----------------------------------------------------------
    //                       MARK: - Variables -
    // ----------------------------------------------------------
    private var cbManager: CBCentralManager!
    private let beaconOperationsQueue = DispatchQueue(label: "beacon_operations_queue")
    private var isScanningStart = false
    
    public var IsShowAlertWhenBluetoothIsOFF = false
    public var IsBluetoothOn = true
    
    private var timer: Timer!
    private var services = [CBUUID]()
    
    private var seenEddystoneCache = [String: [String: AnyObject]]()
    
    public typealias connectcompletionBLock = ((CBPeripheral, Error?) -> Void)
    private var connectcompletion: connectcompletionBLock!
    private var connectablePeripheral: CBPeripheral?
    
    override init() {
        super.init()
        cbManager = CBCentralManager(delegate: self, queue: beaconOperationsQueue, options: nil)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    // TO start scanning Ble Devices
    public func StopScan() {
        cbManager.stopScan()
        isScanningStart = false
    }
    
    private func ShowMessageDialougue(message: String) {
        
        let alert = UIAlertController(title: kAppName, message: message, preferredStyle: .alert)
        let okaction = UIAlertAction(title: kOk, style: .cancel, handler: nil)
        alert.addAction(okaction)
        
        DispatchQueue.main.async {
            UIApplication.shared.delegate?.window!?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - CBCentralManagerDelegate Methods -
// ----------------------------------------------------------
extension BLEManager: CBCentralManagerDelegate {
    
    // For checking bluetooth is on or off
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state != .poweredOff {
            IsBluetoothOn = true
            
        } else {
            isScanningStart = false
            IsBluetoothOn = false
            ShowMessageDialougue(message: kTurnOnBluetooth)
        }
    }
    
    // To get nearest bleDevices
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {}
}
