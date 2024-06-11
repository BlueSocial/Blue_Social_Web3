//
//  LocationManager.swift
//  Blue
//
//  Created by Blue.

import Foundation
import GoogleMaps

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static var shared: LocationManager = LocationManager()
    
    var currentCoordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager?
    
    internal typealias MapAuthorizationStatusCompletionBlock = ((_ isPermissionGranted: Bool) -> ())
    public var mapAuthorizationStatusCompletion: MapAuthorizationStatusCompletionBlock?
    
    func checkLocationAuthorization() {
        
        switch self.locationManager?.authorizationStatus {
                
            case .notDetermined:
                self.locationManager?.requestWhenInUseAuthorization()
                
            case .restricted, .denied:
                self.handleAuthorizationRestriction()
                
            case .authorizedWhenInUse, .authorizedAlways:
                // Location services authorized, proceed with location-based features
                self.handleAuthorizationGranted()
                
            case .none:
                break
                
            @unknown default:
                print("Unexpected authorization status")
        }
    }
    
    func setupLocationManager() {
        
        if self.locationManager != nil {
            return
            
        } else {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
        }
    }
    
    // ----------------------------------------------------------
    //         MARK: - internal Function -
    // ----------------------------------------------------------
    internal func mapAuthorizationStatusCallBack(completion: @escaping MapAuthorizationStatusCompletionBlock) {
        self.mapAuthorizationStatusCompletion = completion
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.checkLocationAuthorization() // Re-evaluate authorization status
    }
    
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager?.stopMonitoringSignificantLocationChanges()
        LocationManager.shared.currentCoordinate = manager.location!.coordinate
        self.locationManager?.stopUpdatingLocation()
    }
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
    
    func handleAuthorizationRestriction() {
        
        // Inform the user about the restriction and potentially provide options to enable access
        UIApplication.topViewController()?.showAlertWith2Buttons(title: kAppName, message: "Allow to access location to keep track of where your interactions take place.", btnOneName: "Cancel", btnTwoName: "Setting", completion: { btnAction in
            
            if btnAction == 2 {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            }
        })
        
        // Call mapAuthorizationStatusCompletion with false if needed
        self.mapAuthorizationStatusCompletion?(false)
    }
    
    func handleAuthorizationGranted() {
        
        // Enable location-based features here
        print("Location Full Access")
        
        // Call mapAuthorizationStatusCompletion with true if needed
        self.mapAuthorizationStatusCompletion?(true)
    }
}
