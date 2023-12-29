//
//  AppDelegate.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/20/23.
//

import UIKit
import AFNetworking
import FirebaseCore
import AppTrackingTransparency
import AdSupport

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var win: UIWindow?
    
    var inBackground = false
    
    // 在后台的时间
    var inBackgroundTime = Date()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 冷启动
        GlobalParameters.shared.isHotStart = false
        
        win = UIWindow(frame: UIScreen.main.bounds)
        win?.backgroundColor = .black
        let openLodingVC = OpenLodingController()
        win?.rootViewController = openLodingVC
        win?.makeKeyAndVisible()
        
        setupConfig()
        
        return true
    }
    
    func setupConfig() {
        
        FirebaseApp.configure()
        SSConnect.shared.setupConfig()

        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { status in
            
            if SSConnect.shared.status == .processing { return }
            
            if status == .reachableViaWWAN || status == .reachableViaWiFi {
                                
                NotificationCenter.default.post(name: OpenLodingProgressDidChangeKey, object: nil, userInfo: ["progress": 0.25] as [String:Float])
                
                FirebaseConfig.shared.fetchConfig { finish in
                    
                    // 请求广告
                    HomeAdMob.shared.requestAd(complete: nil)
                    ResultAdMob.shared.requestAd(complete: nil)
                    InterstitialAdMob.shared.requestAd(complete: nil)
                    OpenAdMob.shared.requestAd { isSuccess in
                        
                        NotificationCenter.default.post(name: OpenLodingProgressDidChangeKey, object: nil, userInfo: ["progress": 1] as [String:Float])
                    }
                }
            }
        }
        AFNetworkReachabilityManager.shared().startMonitoring()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        guard inBackground else { return }
        inBackground = false

        if let root = application.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
            
            if !(root.topViewController is OpenLodingController) {
                
                // 热启动
                GlobalParameters.shared.isHotStart = true
                if Date().timeIntervalSince(inBackgroundTime) > 3 {
                    
                    if let adVC = root.topViewController?.presentedViewController {
                        adVC.dismiss(animated: false)
                    }
                    let openLodingVC = OpenLodingController()
                    root.topViewController?.navigationController?.pushViewController(openLodingVC, animated: false)
                    
                    // 请求广告
                    HomeAdMob.shared.requestAd(complete: nil)
                    if !ResultAdMob.shared.isEffective() {
                        ResultAdMob.shared.requestAd(complete: nil)
                    }
                    InterstitialAdMob.shared.requestAd(complete: nil)
                    if OpenAdMob.shared.isEffective() {
                        
                        NotificationCenter.default.post(name: OpenLodingProgressDidChangeKey, object: nil, userInfo: ["progress": 1] as [String:Float])
                    }else {
                        
                        NotificationCenter.default.post(name: OpenLodingProgressDidChangeKey, object: nil, userInfo: ["progress": 0.5] as [String:Float])
                        OpenAdMob.shared.requestAd { isSuccess in
                            
                            NotificationCenter.default.post(name: OpenLodingProgressDidChangeKey, object: nil, userInfo: ["progress": 1] as [String:Float])
                        }
                    }
                }
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        inBackground = true
        inBackgroundTime = Date()
    }
}

