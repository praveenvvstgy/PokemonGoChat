//
//  LocationHelper.swift
//  PokemonChat
//
//  Created by Praveen Gowda I V on 7/26/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation
import CoreLocation
import PermissionScope

class LocationHelper: NSObject {
    
    static let sharedHelper = LocationHelper()
    
    var currentLocation: CLLocation!
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    func showLocationPrompt() {
        let pscope = PermissionScope(backgroundTapCancels: false)
        pscope.closeButton.hidden = true
        pscope.addPermission(LocationAlwaysPermission(), message: "We use this to find messages near you \nand attach your location to your posts")
        pscope.show({ finished, results in
            print("got results \(results)")
            }, cancelled: { (results) -> Void in
                print("thing was cancelled")
        })
    }

    
}

extension LocationHelper: CLLocationManagerDelegate {
    
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location
        print("Location changed to: \(manager.location)")
        NSNotificationCenter.defaultCenter().postNotificationName("locationChanged", object: currentLocation)
    }
    
}