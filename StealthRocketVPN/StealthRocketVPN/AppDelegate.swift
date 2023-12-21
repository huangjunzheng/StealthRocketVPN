//
//  AppDelegate.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/20/23.
//

import UIKit
import AFNetworking

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var win: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        win = UIWindow(frame: UIScreen.main.bounds)
        win?.backgroundColor = .black
        let openLodingVC = OpenLodingController()
        win?.rootViewController = openLodingVC
        win?.makeKeyAndVisible()
        
        setupConfig()
        
        return true
    }
    
    func setupConfig() {
        
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { status in
            
            if status == .reachableViaWWAN || status == .reachableViaWiFi {
                
                NotificationCenter.default.post(name: OpenLodingProgressDidChangeKey, object: nil, userInfo: ["progress": 1] as [String:Float])
            }
        }
        AFNetworkReachabilityManager.shared().startMonitoring()
    }
}

