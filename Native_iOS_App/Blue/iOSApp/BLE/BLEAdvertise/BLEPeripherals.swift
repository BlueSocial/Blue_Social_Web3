//
//  BLEPeripherals.swift
//  Blue
//
//  Created by Blue.

import UIKit
import CoreBluetooth
import Foundation

public class BLEPeripherals: NSObject {
    
    static let shared = BLEPeripherals()
    
    var peripheralManager: CBPeripheralManager!
    var service1: CBMutableService!
    
    let advertisementServiceUUID = CBUUID(string: SERVICES.ADVERTISEMENT_DISCOVER_SERVICE_UUID)
    let readCharacteristicUUID = CBUUID(string: CHAR.READ_CHAR)
    
    public typealias StartAdvertisementCompletionBlock = ((_ isSucess: Bool, _ msg: String, _ error: Bool) -> Void)
    private var startAdvertisementCompletion: StartAdvertisementCompletionBlock!
    
    public typealias StopAdvertisementCompletionBlock = ((_ isSucess: Bool, _ msg: String, _ error: Bool) -> Void)
    private var stopAdvertisementCompletion: StartAdvertisementCompletionBlock!
    
    private var peripheralName: String!
    var isStartAdvertising = false
    
    public override init() {
        super.init()
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        self.peripheralManager.delegate = self
    }
    
    public func startAdvertising(name: String, bleCallback: @escaping StartAdvertisementCompletionBlock) {
        
        self.stopAdvertise()
        self.startAdvertisementCompletion = bleCallback
        
        // Assign peripheralName with Encoded UserID
        self.peripheralName = name
        
        self.perform(#selector(self.startAdvertise), with: nil, afterDelay: 1.5)
    }
    
    @objc fileprivate func startAdvertise() {
        
        let advertisingData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [advertisementServiceUUID.uuidString],
            CBAdvertisementDataLocalNameKey: UserLocalData.UserID // Replace with your desired device name
        ]
        
        do {
            // Convert the dictionary to Data
            let data = try JSONSerialization.data(withJSONObject: advertisingData, options: [])
            
            let mycharacteristic = CBMutableCharacteristic(type: readCharacteristicUUID, properties: .read, value: data, permissions: .readable)
            
            service1 = CBMutableService(type: advertisementServiceUUID, primary: true)
            service1.characteristics = [mycharacteristic]
            
            self.peripheralManager.add(service1)
            
        } catch {
            print("Error converting dictionary to Data: \(error)")
        }
    }
    
    public func stopAdvertise() {
        
        self.peripheralManager.stopAdvertising()
        self.peripheralManager.removeAllServices()
        
        print(":: BLE ADVERTISING STOPPED ::")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            if self.peripheralManager.isAdvertising {
                print("Device is still advertising.")
            } else {
                print("Device has stopped advertising.")
            }
        }
    }
}

extension BLEPeripherals: CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        if (error != nil) {
            // print("Providing the reason for failure: \(error!.localizedFailureReason)")
            
        } else {
            
            let services: NSArray = [service1.uuid]
            
            if self.peripheralManager.isAdvertising {
                self.stopAdvertise()
            }
            
            self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: services, CBAdvertisementDataLocalNameKey: self.peripheralName!])
            
            print(":: BLE ADVERTISING START ::")
        }
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn {
            print("ON")
            
        } else if peripheral.state == .poweredOff {
            print("OFF")
        }
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        if error == nil {
            
            self.isStartAdvertising = true
            
            if self.startAdvertisementCompletion != nil {
                self.startAdvertisementCompletion(true, "", false)
            }
            
            //print(":: peripheralManagerDidStartAdvertising ::")
            print(":: BLE ADVERTISING STARTED ::")
            
        } else {
            
            let errString = error?.localizedDescription ?? "UnknownError"
            print(":: peripheralManagerDidStartAdvertising Error \(errString)")
            self.isStartAdvertising = false
            
            if self.startAdvertisementCompletion != nil {
                self.startAdvertisementCompletion(false, errString, errString == "UnknownError" ? true : false)
            }
        }
    }
}
