//
//  iBeaconManager.swift
//  Blue
//
//  Created by Blue.

import UIKit
import CoreLocation
import UserNotifications
import ObjectMapper

//var beaconManager = iBeaconManager()

class iBeaconManager: NSObject {
    
    // ----------------------------------------------------------
    //                       MARK: - Variables -
    // ----------------------------------------------------------
    typealias completionBlock = (([Beacon]) -> Void)
    var completion: completionBlock!
    
    var locationManager: CLLocationManager!
    var arriBeacon = [iBeacon]()
    var arrBeacon = [Beacon]()
    
    var timerGetAccurateRssi = Timer()
    var timerSendBeacons = Timer()
    var isStartScanning = false
    
    var threadStarted = false
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        self.timerGetAccurateRssi = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.getAccurateRssi), userInfo: nil, repeats: true)
        self.timerSendBeacons = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.sendDevices), userInfo: nil, repeats: true)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    func callGetBulkContentAPIToGetBeaconDetail(beacon: iBeacon) {
        
        let url = BaseURL + APIName.kGetBulkContent
        
        let parameter: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kGetBulkContent,
                                        APIParamKey.kUserId: UserLocalData.UserID,
                                        APIParamKey.kiBeacon: [[APIParamKey.kUUID: beacon.uuid!,
                                                                APIParamKey.kMajor: beacon.major!,
                                                                APIParamKey.kMinor: beacon.minor!,
                                                                APIParamKey.kIsEnter: true]]]
        
        DispatchQueue.global(qos: .background).async {
            
            APIManager.postAPIRequest(postURL: url, parameters: parameter) { (success, message, response) in
                
                if success {
                    
                    if (response?.beacons!.count)! > 0 {
                        
                        self.arrBeacon.append((response?.beacons![0])!)
                        BLEManager.shared.generateNotification(beacon: (response?.beacons![0])!)
                        
                    } else {
                        
                        self.arriBeacon.removeAll(where: { (bec) -> Bool in
                            return bec.uuid == beacon.uuid && bec.major == beacon.major && bec.minor == beacon.minor
                        })
                    }
                }
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func startScan(mycompletion: @escaping completionBlock) {
        
        self.scan()
        self.completion = mycompletion
    }
    
    func stopScan() {
        
        self.completion = nil
        let uuid = UUID(uuidString: kuuidString)!
        let beaconIdentityRegion = CLBeaconIdentityConstraint(uuid: uuid)
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: kAppName)
        self.locationManager.stopMonitoring(for: beaconRegion)
        self.locationManager.stopRangingBeacons(satisfying: beaconIdentityRegion)
    }
    
    private func scan() {
        
        let uuid = UUID(uuidString: kuuidString)!
        let beaconIdentityRegion = CLBeaconIdentityConstraint(uuid: uuid)
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: kAppName)
        self.locationManager.startMonitoring(for: beaconRegion)
        self.locationManager.startRangingBeacons(satisfying: beaconIdentityRegion)
        isStartScanning = true
        
        print(":: iBeacon SCANNING STARTED ::")
    }
    
    @objc func getAccurateRssi() {
        
        for i in 0 ..< self.arriBeacon.count {
            let beacon = self.arriBeacon[i]
            let sumOfRssis = beacon.rssis?.reduce(0, +)
            self.arriBeacon[i].avgRssi = (sumOfRssis! / beacon.rssis!.count)
        }
    }
    
    @objc func sendDevices() {
        
        if self.completion != nil {
            if self.arrBeacon.count > 0 {
                for (_, bec) in self.arriBeacon.enumerated() {
                    _ = self.arrBeacon.contains(where: { (clbec) -> Bool in
                        clbec.avgRssi = bec.avgRssi
                        return clbec.uuid == bec.uuid && clbec.major == "\(bec.major!)" && clbec.minor == "\(bec.minor!)"
                    })
                }
                //print("::: self.arrBeacon : \(self.arrBeacon.map { $0.userDetail?.id })")
                self.completion(self.arrBeacon)
            }
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - CLLocationManagerDelegate Methods -
// ----------------------------------------------------------
extension iBeaconManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    if self.isStartScanning {
                        self.scan()
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        self.extendBackgroundRunningTime()
        
        //print("iBeaconManager :: arriBeacon count: \(self.arriBeacon.count)")
        if self.arriBeacon.count > 0 {
            
            for (index, bec) in arriBeacon.enumerated() {
                
                if !beacons.contains(where: { (clbec) -> Bool in
                    return clbec.uuid.uuidString == bec.uuid && clbec.major == bec.major && clbec.minor == bec.minor
                }) {
                    if self.arriBeacon.count > index {
                        self.arriBeacon.remove(at: index)
                    }
                }
            }
        }
        
        for beacon in beacons {
            
            let index = self.arriBeacon.firstIndex { (storedBeacon) -> Bool in
                return beacon.uuid.uuidString == storedBeacon.uuid && beacon.major == storedBeacon.major && beacon.minor == storedBeacon.minor
            }
            
            if let i = index {
                
                let b = iBeacon(beacon: beacon)
                self.arriBeacon[i].rssis?.append(b.avgRssi!)
                
                if self.arriBeacon[i].rssis!.count > 10 {
                    self.arriBeacon[i].rssis?.remove(at: 0)
                }
                
            } else {
                
                //NEW device found
                let beacon = iBeacon(beacon: beacon)
                self.arriBeacon.append(beacon)
                
                DispatchQueue.global(qos: .background).async {
                    self.callGetBulkContentAPIToGetBeaconDetail(beacon: beacon)
                }
            }
        }
    }
    
    // TODO: BSN-435 - CFRunLoopSourceInvalidate
    //    func extendBackgroundRunningTime() {
    //
    //        if self.backgroundTask != UIBackgroundTaskIdentifier.invalid {
    //            // if we are in here, that means the background task is already running.
    //            // don't restart it.
    //            return
    //        }
    //
    //        print("Attempting to extend background running time")
    //
    //        self.backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "DummyTask", expirationHandler: {
    //            UIApplication.shared.endBackgroundTask(self.backgroundTask)
    //            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
    //        })
    //
    //        if threadStarted {
    //            print("Background task thread already started.")
    //
    //        } else {
    //
    //            threadStarted = true
    //
    //            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
    //                while (true) {
    //                    // A dummy tasks must be running otherwise iOS suspends immediately
    //                    Thread.sleep(forTimeInterval: 1);
    //                }
    //            }
    //        }
    //    }
    
    func extendBackgroundRunningTime() {
        
        if self.backgroundTask != UIBackgroundTaskIdentifier.invalid {
            // if we are in here, that means the background task is already running.
            // don't restart it.
            return
        }
        
        print("Attempting to extend background running time")
        
        self.backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "DummyTask", expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        })
        
        if threadStarted {
            print("Background task thread already started.")
        } else {
            threadStarted = true
            
            DispatchQueue.global(qos: .default).async {
                // Add a run loop to keep the background task alive
                let runLoop = RunLoop.current
                let dummyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    // Dummy tasks to prevent iOS from suspending immediately
                }
                runLoop.add(dummyTimer, forMode: .default)
                runLoop.run()
            }
        }
    }
    
    func encode(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    func decode(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
}
