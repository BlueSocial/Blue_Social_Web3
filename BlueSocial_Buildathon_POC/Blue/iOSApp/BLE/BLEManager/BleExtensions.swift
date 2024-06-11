//
//  BLEManager.swift
//  Blue
//
//  Created by Blue.


import Foundation
import CoreBluetooth
import UIKit

public extension CBPeripheral {
    
    func getperipheralid() -> String {
        return identifier.uuidString.uppercased()
    }
    
    func Isconnected() -> Bool {
        return state == .connected
    }
}

// ----------------------------------------------------------
//                       MARK: - For AdvertisementData -
// ----------------------------------------------------------
public extension Dictionary where Key == String, Value == Any {
    
    func peripheralName() -> String? {
        return self[CBAdvertisementDataLocalNameKey] as? String
    }
    
    func overFlowService() -> String? {
        
        if let serviceIDS = self[CBAdvertisementDataOverflowServiceUUIDsKey] as? NSArray {
            return (serviceIDS.firstObject as! CBUUID).uuidString
        }
        return nil
    }
    
    func primaryService() -> String? {
        
        if let serviceIDS = self[CBAdvertisementDataServiceUUIDsKey] as? NSArray {
            return (serviceIDS.firstObject as! CBUUID).uuidString
        }
        return nil
    }
    
    func IsConnectable() -> Bool {
        return (self[CBAdvertisementDataIsConnectable] as! Int == 1) ? true:false
    }
    
    func standardServiceName() -> String? {
        
        if let serviceIDS = self[CBAdvertisementDataServiceUUIDsKey] as? NSArray {
            
            for seviceid in serviceIDS {
                
                let key = servicesDictionary.keys.filter({$0 == "\(seviceid)"})
                
                if key.count > 0 {
                    return servicesDictionary[key[0]]
                }
            }
        }
        return nil
    }
    
    func standardServiceid() -> String? {
        
        if let serviceIDS = self[CBAdvertisementDataServiceUUIDsKey] as? NSArray {
            
            for seviceid in serviceIDS {
                return "\(seviceid)"
            }
        }
        return nil
    }
    
    func getManufacturerData() -> String? {
        
        if let manufacturerData = self[CBAdvertisementDataManufacturerDataKey] as? Data {
            return manufacturerData.hexEncodedString()
        }
        return nil
    }
}

public extension String {
    
    func isValidHexValue() -> Bool {
        
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        guard uppercased().rangeOfCharacter(from: chars) == nil else { return false }
        return true
    }
    
    func trimString() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var bytes: Array<UInt8> {
        return data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }
}

// ----------------------------------------------------------
//                       MARK: - For Service -
// ----------------------------------------------------------
public extension CBService {
    
    func getUUIDString() -> String {
        return uuid.uuidString.uppercased()
    }
    
    func servicename() -> String {
        return "\(servicesDictionary[uuid.uuidString.uppercased()] ?? "CUSTOM SERVICE")"
    }
}

// ----------------------------------------------------------
//                       MARK: - For Characteristic -
// ----------------------------------------------------------
public extension CBCharacteristic {
    
    func getUUIDString() -> String {
        return uuid.uuidString.uppercased()
    }
    
    func isContainReadProperty() -> Bool {
        return properties.contains(.read)
    }
    
    func isContainWriteProperty() -> Bool {
        return properties.contains(.write)
    }
    
    func isContainNotifyProperty() -> Bool {
        return properties.contains(.notify)
    }
    
    func getProperties() -> String {
        
        var strPermission = ""
        
        if properties.contains(.read) {
            strPermission = "Read "
        }
        
        if properties.contains(.write) {
            strPermission = strPermission + "Write "
        }
        
        if properties.contains(.notify) {
            strPermission = strPermission + "Notify"
        }
        return strPermission
    }
}

// ----------------------------------------------------------
//                       MARK: - For Data -
// ----------------------------------------------------------
extension Data {
    
    var bytes: Array<UInt8> {
        return Array(self)
    }
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
