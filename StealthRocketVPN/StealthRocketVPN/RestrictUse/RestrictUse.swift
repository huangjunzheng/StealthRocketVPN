//
//  RestrictUse.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/28/23.
//

import UIKit
import CoreLocation

class RestrictUse: NSObject {

    static let shared = RestrictUse()
    
    let manager = CLLocationManager()
    
    var locationdidComplete: ((Bool) -> Void)?
    
    
    // 判断使用是否受限
    func isRestrictUse(complete: ((Bool) -> Void)?) {
        
        // 先判断系统语言环境
        let languageIdentifier = Locale.current.identifier
        if languageIdentifier.contains("zh_CN") || languageIdentifier.contains("zh_HK") || languageIdentifier.contains("fa_IR") {
            
            complete?(true)
            return
        } else {
            
            // 判断定位
            locationdidComplete = complete
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            manager.requestWhenInUseAuthorization()
            if #available(iOS 14.0, *) {
                if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
                    manager.startUpdatingLocation()
                }
            } else {
                if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    manager.startUpdatingLocation()
                }
            }
        }
    }
}


extension RestrictUse: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else {
            manager.stopUpdatingLocation()
            locationdidComplete?(false)
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in

            guard let self = self else {
                manager.stopUpdatingLocation()
                self?.locationdidComplete?(false)
                return
            }
            if let country = placemarks?.first?.isoCountryCode {
                #if DEBUG
                self.locationdidComplete?(false)
                #else
                let result = ["CN", "HK", "IR"].contains(country)
                self.locationdidComplete?(result)
                #endif
            }else {
                self.locationdidComplete?(false)
            }
        }
        manager.stopUpdatingLocation()
    }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        manager.stopUpdatingLocation()
        locationdidComplete?(false)
    }
}
