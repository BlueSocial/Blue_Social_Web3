//
//  BLEManager.swift
//  Blue
//
//  Created by Blue.

import UIKit
import CoreBluetooth
import UserNotifications

protocol BLEManagerDelegate: AnyObject {
    func deviceWentOutOfRange(_ device: BLEDevice)
}

public class BLEManager: NSObject {
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    static let shared = BLEManager()
    
    var centralManager: CBCentralManager!
    var isScanningStart = false
    
    private var arrBLEDevice = [String: BLEDevice]()
    
    private var timer: Timer!
    private var timerLostBeacon: Timer!
    private var timerConnectionTimeOut: Timer!
    
    private var scanServices = [CBUUID]()
    
    public typealias FoundBLEDeviceCompletionBlock = ((_ bleDevice: BLEDevice, _ msg: String, _ isNew: Bool) -> Void)
    private var foundBLEDeviceCompletion: FoundBLEDeviceCompletionBlock!
    
    public typealias OutRangeCompletionBlock = ((BLEDevice) -> Void)
    private var outRangeCompletion: OutRangeCompletionBlock!
    
    typealias DisconnectDeviceCompletionBlock = (Bool) -> Void
    private var disconnectDeviceCompletion: DisconnectDeviceCompletionBlock!
    
    typealias AutoDisconnectCompletionBlock = (BLEDevice) -> Void
    private var autoDisconnectCompletion: AutoDisconnectCompletionBlock?
    
    public typealias BluetoothStateCompletionBlock = ((_ isON: Bool) -> Void)
    private var bluetoothStateCompletion: BluetoothStateCompletionBlock?
    typealias AuthorizationStatusCallback = (Bool) -> Void
    private var authorizationStatusCallback: AuthorizationStatusCallback?
    var isBlePermissionGivenInTour = false
    var isBluetoothON = false
    var isBLEPermissionGiven = false
    
    public typealias MapAuthorizationStatusCompletionBlock = ((_ isPermissionGranted: Bool) -> ())
    private var mapAuthorizationStatusCompletion: MapAuthorizationStatusCompletionBlock?
    
    weak var delegate: BLEManagerDelegate?
    
    // Kalman Filter on RSSI
    fileprivate var processNoise: Double = 0.125
    fileprivate var measurementNoise: Double = 0.8
    
    fileprivate var estimatedRSSI = 0.0 //calculated rssi
    fileprivate var errorCovarianceRSSI = 0.0 // calculated covariance
    fileprivate var isInitialized = false // initialization flag
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getAccurateRssiBeacons), userInfo: nil, repeats: true)
        
        //To consider beacon out range call it every 3 seconds
        self.timerLostBeacon = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(considerBeaconOutRange), userInfo: nil, repeats: true)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Fuctions -
    // ----------------------------------------------------------
    // Function to check and prompt for BLE permission and Bluetooth state
    func checkBluetoothPermissionAndState(completion: @escaping AuthorizationStatusCallback) {
         self.authorizationStatusCallback = completion
         
         let authorization = CBCentralManager.authorization
         
         switch authorization {
         case .notDetermined :
             print("Not determined")
                 
        case .restricted, .denied:
             print("denied")
             isBLEPermissionGiven = false
             if isBlePermissionGivenInTour == true {
                 handleAuthorizationRestriction()
             }
         case .allowedAlways:
             isBLEPermissionGiven = true
             self.authorizationStatusCallback?(true)
         @unknown default:
             print("default BT")
         }
     }
    
    func handleAuthorizationRestriction() {
        
        // Inform the user about the restriction and potentially provide options to enable access
        UIApplication.topViewController()?.showAlertWith2Buttons(title: kAppName, message: "Bluetooth permission is currently disabled for the application. Enable Bluetooth from the application settings.", btnOneName: "Setting", btnTwoName: "Cancel", completion: { btnAction in
            
            if btnAction == 1 {
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }
        })
        
        // Call mapAuthorizationStatusCompletion with false if needed
        self.mapAuthorizationStatusCompletion?(false)
    }
    
    func handleAuthorizationGranted() {
        
        // Enable location-based features here
        print("BLE Full Access")
        
        // Call mapAuthorizationStatusCompletion with true if needed
        self.mapAuthorizationStatusCompletion?(true)
    }
    
    func autoDisconnect(myCompletion: @escaping AutoDisconnectCompletionBlock) {
        
        self.autoDisconnectCompletion = myCompletion
    }
    
    func disConnect(device: CBPeripheral, myCompletion: @escaping DisconnectDeviceCompletionBlock) {
        
        self.centralManager.cancelPeripheralConnection(device)
        self.disconnectDeviceCompletion = myCompletion
    }
    
    // TO start scanning Ble Devices
    public func startScanning(services: [String]?, myCompletion: @escaping FoundBLEDeviceCompletionBlock) {
        
        self.foundBLEDeviceCompletion = myCompletion
        
        self.scanServices.removeAll()
        
        // Scan BLE Device with DISCOVER_SERVICE_UUID: "000055DD-0000-1000-8000-00805F9B34FB"
        if let services = services {
            for uuid in services {
                self.scanServices.append(CBUUID(string: uuid))
            }
        }
        
        self.perform(#selector(self.startScan), with: nil, afterDelay: 1.0)
    }
    
    @objc private func startScan() {
        
        if self.isScanningStart == false {
            
            self.clearAllBLEDevices()
            
            if self.centralManager == nil {
                self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
            }
            
            self.centralManager.delegate = self
            self.centralManager.scanForPeripherals(withServices: self.scanServices, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            self.isScanningStart = true
            
            print(":: BLE SCANNING STARTED ::")
        }
    }
    
    private func clearAllBLEDevices() {
        
        self.arrBLEDevice.removeAll()
    }
    
    public func getBluetoothState(myCompletion: @escaping BluetoothStateCompletionBlock) {
        self.bluetoothStateCompletion = myCompletion
    }
    
    public func stopScanning() {
        
        self.clearAllBLEDevices()
        self.centralManager.stopScan()
        self.isScanningStart = false
        
        print(":: BLE SCANNING STOPPED ::")
    }
    
    @objc private func getAccurateRssiBeacons() {
        
        for device in self.arrBLEDevice.values {
            
            device.arrRSSI = device.arrRSSI.sorted()
            
            if device.arrRSSI.count > 10 {
                
                let upperDeleteCount = (device.arrRSSI.count * 20) / 100
                let lowerDeleteCount = (device.arrRSSI.count * 20) / 100
                
                for _ in 0 ..< upperDeleteCount {
                    device.arrRSSI.removeFirst()
                }
                
                for _ in 0 ..< lowerDeleteCount {
                    device.arrRSSI.removeLast()
                }
            }
            
            let totalRssis = device.arrRSSI.reduce(0, +)
            device.avgRSSI = totalRssis / device.arrRSSI.count
            //print("device.uuid :: \(device.uuid ?? ""), device.avgRSSI :: \(device.avgRSSI ?? 0)")
            let bleDevice = calculateDistanceInFeet(device: device)
            //print("bleDevice.uuid :: \(bleDevice.uuid ?? ""), bleDevice.avgRSSI :: \(bleDevice.avgRSSI ?? 0), bleDevice.distanceInFeet :: \(bleDevice.distanceInFeet ?? 0)")
            self.foundBLEDeviceCompletion(bleDevice, "", false)
        }
    }
    
    public func getOutRangeDevice(mycompletion: @escaping OutRangeCompletionBlock) {
        self.outRangeCompletion = mycompletion
    }
    
    //Check device is out range or not
    @objc private func considerBeaconOutRange() {
        
        //logfile.appendNewText(text: "Beacon outrange count method call")
        for device in self.arrBLEDevice.values {
            
            device.count += 1
            device.inRange = false
            //print("Device count:", device.count)
            // logfile.appendNewText(text: "Device count: \(device.count) isInRange: \(device.inRange) isGrayed: \(device.isGrayed)")
            
            //Outrange time and gray time set from setting screen
            if device.count >= 4 {
                
                print("ConsiderBeaconOutRange count is now 4:", device.count)
                self.arrBLEDevice.removeValue(forKey: device.uuid)
                self.delegate?.deviceWentOutOfRange(device)
                
                print("device.uuid: \(device.uuid ?? "")")
                print("device.localName: \(device.localName ?? "")")
            }
        }
    }
    
    //Calculate distance in meter on rssi and txpower
    private func calculateDistanceInFeet(device: BLEDevice) -> BLEDevice {
        
        let txPower = -59
        let strDistance = calculatorDistance(txPower: txPower, avarageRssi: device.avgRSSI)
        device.distanceInFeet = Float(strDistance)
        return device
    }
    
    private func calculatorDistance(txPower: Int, avarageRssi: Int) -> String {
        
        var accuracy = 0.0
        
        if (avarageRssi == 0) {
            accuracy = -1.0 // if we cannot determine accuracy, return -1.
        }
        
        let ratio = Double(avarageRssi) * 1.0 / Double(txPower)
        if (ratio < 1.0) {
            accuracy = pow(ratio, 10)
        } else {
            accuracy = (0.89976) * pow(ratio, 7.7095) + 0.111
        }
        
        var distanceFloatDisplay = "0.0"
        
        if (accuracy < 1) {
            distanceFloatDisplay = "\(String(format: "%.1f", Double(accuracy)))"
        } else if (accuracy > 1 && accuracy < 4) {
            distanceFloatDisplay = "\(String(format: "%.1f", Double(accuracy)))"
        } else {
            distanceFloatDisplay = "\(String(format: "%.1f", Double(accuracy)))"
        }
        return distanceFloatDisplay
    }
    
    private func applyKalmanFilter(RSSI: Int) -> Double {
        
        var priorRSSI = 0.0
        var kalmanGain = 0.0
        var priorErrorCovarianceRSSI = 0.0
        
        if (!isInitialized) {
            
            priorRSSI = Double(RSSI)
            priorErrorCovarianceRSSI = 1
            isInitialized = true
            
        } else {
            
            priorRSSI = estimatedRSSI
            priorErrorCovarianceRSSI = errorCovarianceRSSI + processNoise
        }
        
        kalmanGain = priorErrorCovarianceRSSI / (priorErrorCovarianceRSSI + measurementNoise)
        estimatedRSSI = priorRSSI + (kalmanGain * (Double(RSSI) - priorRSSI))
        errorCovarianceRSSI = (1 - kalmanGain) * priorErrorCovarianceRSSI
        
        return estimatedRSSI
    }
    
    func generateNotification(beacon: Beacon) {
        
        let content = UNMutableNotificationContent()
        
        if beacon.isBeacon {
            content.title = beacon.title!
            content.body = beacon.descriptionField ?? ""
            content.userInfo = beacon.toJSON()
            
        } else { //Nearby message use this localNotification
            
            content.title = beacon.descriptionField ?? ""
            content.userInfo = beacon.toJSON()
            
            if beacon.isTapSocial {
                content.body = ""
            } else {
                content.body = kBeSocial
            }
        }
        
        content.badge = 0
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: beacon.beaconid ?? "", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
        })
    }
}

// ----------------------------------------------------------
//                       MARK: - CBCentralManagerDelegate -
// ----------------------------------------------------------
extension BLEManager: CBCentralManagerDelegate {
    
    // For checking bluetooth is on or off
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
                
            case .unknown:
                print("central.state is .unknown")
                
            case .resetting:
                print("central.state is .resetting")
                
            case .unsupported:
                print("central.state is .unsupported")
                
            case .unauthorized:
                print("central.state is .unauthorized")
                
                DispatchQueue.main.async {
                    BLEManager.shared.checkBluetoothPermissionAndState { isPermissionGranted in
                        if isPermissionGranted {
                            print("Bluetooth permission granted")
                        } else {
                            print("Bluetooth permission denied")
                            BLEManager.shared.handleAuthorizationRestriction()
                            // Handle permission denied scenario here
                        }
                    }
                }
                
            case .poweredOff:
                print("central.state is .poweredOff")
                self.isScanningStart = false
                self.isBluetoothON = false
                self.bluetoothStateCompletion?(false)
                
            case .poweredOn:
                print("central.state is .poweredOn")
                self.isBluetoothON = true
                self.bluetoothStateCompletion?(true)
                
            @unknown default:
                print("central.state is .default")
                break
        }
    }
    
    // To get nearest bleDevices
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        if (advertisementData.peripheralName() == nil && advertisementData.peripheralName() == "") { return }
        
        let filteredRSSI = Int(self.applyKalmanFilter(RSSI: RSSI.intValue))
        
        if let existingBLEDevice = self.arrBLEDevice[peripheral.identifier.uuidString] {
            
            //print("Existing BLE LocalName is : \(existingBLEDevice.localName ?? "\(existingBLEDevice.name ?? "")")")
            
            if existingBLEDevice.arrRSSI.count > 15 {
                existingBLEDevice.arrRSSI.remove(at: 0)
            }
            
            existingBLEDevice.name = peripheral.name
            existingBLEDevice.localName = advertisementData.peripheralName()
            existingBLEDevice.rssi = filteredRSSI
            existingBLEDevice.arrRSSI.append(filteredRSSI)
            existingBLEDevice.count = 0
            existingBLEDevice.inRange = true
            
            if self.foundBLEDeviceCompletion != nil {
                self.foundBLEDeviceCompletion(existingBLEDevice, "Existing BLE LocalName is: \(existingBLEDevice.localName ?? "\(existingBLEDevice.name ?? "")")", false)
            }
            
            self.arrBLEDevice[peripheral.identifier.uuidString] = existingBLEDevice
            
        } else {
            
            let newBLEDevice = BLEDevice(peripheral: peripheral, advertisementdata: advertisementData, Rssi: filteredRSSI)
            
            print("New Found BLE LocalName is : \(newBLEDevice.localName ?? "\(newBLEDevice.name ?? "")")")
            print("New Found BLE LocalName is : \(newBLEDevice.localName ?? "")")
            print("New Found BLE Name is : \(newBLEDevice.name ?? "")")
            
            if self.foundBLEDeviceCompletion != nil {
                self.foundBLEDeviceCompletion(newBLEDevice, "New Found BLE LocalName is: \(newBLEDevice.localName ?? "\(newBLEDevice.name ?? "")")", true)
            }
            
            self.arrBLEDevice[newBLEDevice.uuid] = newBLEDevice
        }
    }
    
    func removeDevice(bleDevice: BLEDevice) {
        
        print(self.arrBLEDevice.count)
        print(self.arrBLEDevice[bleDevice.uuid] as Any)
        
        self.arrBLEDevice[bleDevice.uuid] = nil
        
        print(self.arrBLEDevice.count)
        print(self.arrBLEDevice[bleDevice.uuid] as Any)
    }
}

class UserIDEncoder {
    
    static let BASE62 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    static let BASE89 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()-_+=[]{}|;:,./<>?"
    
    func encode(userId: Int64) -> String {
        
        let base = Self.BASE62.count
        var id = userId
        var encoded = ""
        
        for _ in 0 ..< 5 {
            
            let remainder = Int(id % Int64(base))
            id /= Int64(base)
            encoded = String(Self.BASE62[Self.BASE62.index(Self.BASE62.startIndex, offsetBy: remainder)]) + encoded
        }
        
        return encoded
    }
    
    func decode(encoded: String) -> Int64 {
        
        let base = Self.BASE62.count
        var decoded = Int64(0)
        
        for char in encoded {
            
            if let index = Self.BASE62.firstIndex(of: char) {
                decoded = decoded * Int64(base) + Int64(index.utf16Offset(in: Self.BASE62))
            }
        }
        
        return decoded
    }
    
    /*
     
     // We can encode and decode upto 8Digit of userID as below:
     if let int64DeviceName = Int64("99999999") {
     
     let encodedDeviceName = UserIDEncoder().encode(userId: int64DeviceName)
     print("Current User's encodedDeviceName: \(encodedDeviceName)")
     
     let decodedInt64DeviceName = UserIDEncoder().decode(encoded: encodedDeviceName)
     print("Current User's decodedDeviceName: \(decodedInt64DeviceName)")
     }
     
     */
}
