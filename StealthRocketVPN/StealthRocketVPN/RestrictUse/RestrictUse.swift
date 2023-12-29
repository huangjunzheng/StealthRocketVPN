//
//  RestrictUse.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/28/23.
//

import UIKit
import CoreLocation
import ipinfoKit

class RestrictUse: NSObject {

    static let shared = RestrictUse()
    
    let manager = CLLocationManager()
    
    var locationdidComplete: ((Bool) -> Void)?
    
    
    // 判断使用是否受限
    func isRestrictUse(complete: ((Bool) -> Void)?) {
        
        isRestrict_IP { [weak self] ipRestrict in
            
            if !ipRestrict {
                
                guard let self = self else {
                    complete?(false)
                    return
                }
                // 判断定位
                self.locationdidComplete = complete
                self.manager.delegate = self
                self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.manager.requestWhenInUseAuthorization()
                if #available(iOS 14.0, *) {
                    if self.manager.authorizationStatus == .authorizedAlways || self.manager.authorizationStatus == .authorizedWhenInUse {
                        self.manager.startUpdatingLocation()
                    }
                } else {
                    if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                        self.manager.startUpdatingLocation()
                    }
                }
                self.locationdidComplete = { [weak self] locationRestrict in
                    
                    guard let self = self else {
                        complete?(false)
                        return
                    }
                    if !locationRestrict {
                        
                        let languageIdentifier = Locale.current.identifier
                        if languageIdentifier.contains("zh_CN") || languageIdentifier.contains("zh_HK") || languageIdentifier.contains("fa_IR") {
                            
                            complete?(true)
                            return
                        }else {
                            complete?(false)
                        }
                    }
                }
            }else {
                complete?(false)
            }
        }
    }
    
    private func isRestrict_IP(complete: ((Bool) -> Void)?) {

        getWiFiIP { ip in

            guard let ip = ip else {
                complete?(false)
                return
            }
            IPINFO.shared.getDetails(ip: ip) { [weak self] status, data, msg in

                guard let self = self else {
                    complete?(false)
                    return
                }
                switch status {

                case .success:
                    if let dic = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                        
                        if let country = dic["country"] as? String,
                           country.contains("China"),
                           country.contains("HongKong"),
                           country.contains("Macao"),
                           country.contains("Iran") {
                            complete?(true)
                        }else {
                            complete?(false)
                        }
                    }
                case .failure:
                    complete?(false)
                }
            }
        }
    }
    
    // 获取当前连接的ip
    private func getWiFiIP(completion: @escaping (String?) -> Void) {

        var adds: String?
        var abksex: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&abksex) == 0 {

            var ptr = abksex
            while ptr != nil {

                defer { ptr = ptr?.pointee.ifa_next }

                let mykirh = ptr?.pointee
                let babcat = mykirh?.ifa_addr.pointee.sa_family
                if babcat == UInt8(AF_INET) || babcat == UInt8(AF_INET6) {

                    let name = String(cString: (mykirh?.ifa_name)!)
                    if name == "en0" {

                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(mykirh?.ifa_addr, socklen_t(mykirh?.ifa_addr.pointee.sa_len ?? 0), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        adds = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(abksex)
        }
        completion(adds)
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
                let result = ["CN", "HK", "IR", "MO"].contains(country)
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
