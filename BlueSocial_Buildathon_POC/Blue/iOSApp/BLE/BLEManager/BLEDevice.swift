//
//  BLEDevice.swift
//  Blue
//
//  Created by Blue.

import UIKit
import CoreBluetooth

public class BLEDevice: NSObject {
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    @objc public var peripheral: CBPeripheral!
    @objc public var AdvData: [String: Any]!
    @objc public var inRange = Bool()
    @objc public var count = Int()
    @objc public var arrRSSI = [Int]()
    
    public var uuid: String!
    public var name: String?
    public var aliasName: String?
    public var localName: String?
    public var beaconTypeName: String?
    public var standardServiceName: String?
    public var manufacturerData: String?
    public var isConnectable: Bool?
    
    public var avgRSSI: Int!
    public var distanceInFeet: Float!
    
    public var serivces = [Service]()
    private var operationalCharacteristic: CBCharacteristic!
    
    public typealias ConnectionComlition = ((Bool, BLEDevice, Error?) -> Void)
    private var connectionComlition: ConnectionComlition!
    
    public typealias updateRSSI = (Int) -> Void
    @objc var getUpdateRSSI: updateRSSI!
    
    //Read Data Complication
    public typealias ReadDeviceData = (Bool, [UInt8]) -> Void
    @objc var readDeviceData: ReadDeviceData!
    
    //Write Data Complication
    public typealias WriteDeviceData = (Bool, [UInt8]) -> Void
    @objc var writeDeviceData: WriteDeviceData?
    
    private var connectionTime = Timer()
    private var readLogTime = Timer()
    
    private var deviceProgressStatus: DeviceProgress = .none
    
    @objc public var lastUpdatedDateTime = Date()
    
    @objc public var rssi = Int()
    @objc public var distance = 0.0
    
    @objc public var averageInterval = [Int]()
    
    @objc public var packageCount = 1
    @objc public var intervalNanos = 0
    @objc public var prevCurrentTime = 0
    
    @objc public var privacyKey: [UInt8] = [0x41,0x4D,0xC4,0x7B,0xF2,0x79,0x4E,0x7F,0x15,0x4C,0x45,0x41,0x92,0x49,0x69,0x21]
    
    @objc public override init() {}
    
    // ----------------------------------------------------------
    //                       MARK: - Functions -
    // ----------------------------------------------------------
    @objc init(peripheral: CBPeripheral, advertisementdata: [String: Any], Rssi: Int) {
        super.init()
        
        let exactRSSI = Rssi > -1 ? -100: Rssi < -100 ? -100: Rssi
        self.peripheral = peripheral
        self.AdvData = advertisementdata
        self.avgRSSI = exactRSSI
        self.arrRSSI = [exactRSSI]
        
        self.inRange = true
        self.count = 0
        self.uuid = peripheral.identifier.uuidString
        
        self.name                = peripheral.name
        self.localName           = advertisementdata.peripheralName()
        self.standardServiceName = advertisementdata.standardServiceName()
        self.isConnectable       = advertisementdata.IsConnectable()
        self.manufacturerData    = advertisementdata.getManufacturerData()
    }
    
    public func isConnected() -> Bool {
        return peripheral.state == .connected
    }
}

// ----------------------------------------------------------
//                       MARK: - CBPeripheralDelegate -
// ----------------------------------------------------------
extension BLEDevice: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {}
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {}
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {}
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {}
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {}
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {}
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {}
    
    private func writeDataWithResponse(writeData: Data, characteristic: CBCharacteristic) {
        self.peripheral!.writeValue(writeData, for: characteristic, type: .withResponse)
    }
    
    private func writeDataWithoutResponse(writeData: Data, characteristic: CBCharacteristic) {
        self.peripheral!.writeValue(writeData, for: characteristic, type: .withoutResponse)
    }
    
    private func readDataWithCharacteristic(characteristic: CBCharacteristic) {
        self.peripheral!.readValue(for: characteristic)
    }
    
    private func setNotifyWithCharacteristic(characteristic: CBCharacteristic) {
        self.peripheral!.setNotifyValue(true, for: characteristic)
    }
}

public class Service: NSObject {
    
    public var name: String?
    public var uuid: String?
    public var characteristics = [Characterstic]()
    
    public init(service: CBService) {
        super.init()
        
        name = servicesDictionary[service.uuid.uuidString] ?? "Custom Service".uppercased()
        uuid = service.uuid.uuidString
    }
}

public class Characterstic: NSObject {
    
    public var characteristic: CBCharacteristic!
    public var name: String?
    public var uuid: String?
    public var stringValue: String?
    public var base64EncodedStringValue: String?
    public var hexValue: String?
    public var byteArray: [UInt8]?
    public var dataValue: Data?
    public var descriptors = [Descriptor]()
    
    init(characterstic: CBCharacteristic) {
        super.init()
        
        self.characteristic = characterstic
        self.uuid           = characterstic.uuid.uuidString
        self.name           = characteristicDictionary[characterstic.uuid.uuidString] ?? "Custom Characteristic" //.uppercased()
        self.stringValue    = getStringValue()
        self.hexValue       = getHexValue().uppercased()
        self.base64EncodedStringValue = characteristic.value?.base64EncodedString()
        self.dataValue      = characteristic.value
        
        if let newData = dataValue {
            byteArray = Array<UInt8>(newData)
        }
    }
    
    func isNotifiable() -> Bool {
        return characteristic.properties.contains(.notify)
    }
    
    func isReadable() -> Bool {
        return characteristic.properties.contains(.read)
    }
    
    func isWriteable() -> Bool {
        return characteristic.properties.contains(.write)
    }
    
    private func getStringValue() -> String {
        
        var strvalue = ""
        
        if let value = characteristic.value {
            for character in value {
                strvalue = strvalue.appending("\(UnicodeScalar(character))")
            }
        }
        return strvalue
    }
    
    private func getHexValue() -> String {
        
        if let value = characteristic.value {
            return (value.hexEncodedString())
        }
        return ""
    }
}

enum DeviceProgress {
    
    case isConnected
    case read
    case write
    case none
}

enum DescriptorType {
    
    case ExtendedProperties
    case UserDescription
    case ClientConfiguration
    case Serverconfiguration
    case Format
    case AggregateFormat
    case None
}

public class Descriptor: NSObject {
    
    public var descriptor: CBDescriptor!
    public var uuid: String?
    public var title: String?
    public var value: String?
    var type: DescriptorType!
    
    init(descriptor: CBDescriptor) {
        super.init()
        
        self.descriptor = descriptor
        self.uuid       = descriptor.uuid.uuidString
        self.value      = "\(descriptor.value ?? "Custom")"
        
        switch descriptor.uuid.uuidString {
            
        case CBUUIDCharacteristicExtendedPropertiesString:
            guard let properties = descriptor.value as? NSNumber else { break }
            
            self.title = "Extended properties"
            self.type  = .ExtendedProperties
            print("Extended properties: \(properties)")
            
        case CBUUIDCharacteristicUserDescriptionString:
            guard let description = descriptor.value as? NSString else { break }
            
            self.title = "User description"
            self.type  = .UserDescription
            print("User description: \(description)")
            
        case CBUUIDClientCharacteristicConfigurationString:
            guard let clientConfig = descriptor.value as? NSNumber else { break }
            
            self.title = "Client configuration"
            self.type  = .ClientConfiguration
            self.value = "\(clientConfig)"
            print("Client configuration: \(clientConfig)")
            
        case CBUUIDServerCharacteristicConfigurationString:
            guard let serverConfig = descriptor.value as? NSNumber else { break }
            
            self.title = "Server configuration"
            self.type  = .Serverconfiguration
            print("Server configuration: \(serverConfig)")
            
        case CBUUIDCharacteristicFormatString:
            guard let format = descriptor.value as? NSData else { break }
            
            self.title = "Format"
            self.type  = .Format
            print("Format: \(format)")
            
        case CBUUIDCharacteristicAggregateFormatString:
            self.title = "Aggregate Format"
            self.type  = .AggregateFormat
            print("Aggregate Format: (is not documented)")
            
        default:
            self.title = ""
            self.type  = .None
            break
        }
    }
}
