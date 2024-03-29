//
//  LocationManager.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/25/24.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager!
    var authorizationStatusChangedCallback: ((CLAuthorizationStatus) -> Void)?
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        // Check if the app has already been authorized to use location services
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request permission to access location when in use
                self.locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                // Display an alert or UI message to the user indicating that location services are disabled
                // You may provide guidance on how to enable location services in the device settings
                print("Location services are disabled. Please enable in settings.")
                self.authorizationStatusChangedCallback?(.denied)
            case .authorizedAlways, .authorizedWhenInUse:
                // Location services already authorized, no need to request again
                self.authorizationStatusChangedCallback?(.authorizedWhenInUse)
            @unknown default:
                break
            }
        } else {
            // Location services are not enabled on the device
            print("Location services are not enabled.")
            self.authorizationStatusChangedCallback?(.restricted)
        }
    }
    
    // CLLocationManagerDelegate method called when the authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatusChangedCallback?(CLLocationManager.authorizationStatus())
    }
}
