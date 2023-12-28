//
//  OpenAdMob.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit
import GoogleMobileAds

class OpenAdMob: NSObject {

    static let shared = OpenAdMob()
    
    var loadADDate: Date?
    
    var cacheAd: GADAppOpenAd?
    
    // 是否已经重试
    var didTry = false
    
    var didShowComplete: (() -> Void)?
        
    
    func isEffective() -> Bool {
        
        if let loadADDate = loadADDate,
           let _ = cacheAd,
           Int(Date().timeIntervalSince(loadADDate)) < 60*60*1000 {
            return true
        }else {
            return false
        }
    }
    
    func requestAd(complete: ((Bool) -> Void)?) {
//        ca-app-pub-3940256099942544/5575463023
        GADAppOpenAd.load(withAdUnitID: "", request: nil) { [weak self] ad, err in
            
            guard let self = self else {
                self?.didTry = false
                complete?(false)
                return
            }
            
            if err != nil {
                if self.didTry {
                    // 重试后还是失败
                    self.didTry = false
                    self.clearCache()
                    complete?(false)
                }else {
                    // 重试请求
                    self.didTry = true
                    self.requestAd(complete: complete)
                }
                return
            }

            if let ad = ad {
                
                self.didTry = false
                self.cacheAd = ad
                self.loadADDate = Date()
                complete?(true)
            }else {
                
                if self.didTry {
                    // 重试后还是失败
                    self.didTry = false
                    self.clearCache()
                    complete?(false)
                }else {
                    // 重试请求
                    self.didTry = true
                    self.requestAd(complete: complete)
                }
            }
        }
    }
    
    func show(vc: UIViewController, complete: (() -> Void)?) {
        
        didShowComplete = complete
        if let ad = cacheAd {
            
            ad.fullScreenContentDelegate = self
            ad.present(fromRootViewController: vc)
        }else {
            complete?()
        }
    }
    
    func clearCache() {
        
        cacheAd = nil
        loadADDate = nil
    }
}


extension OpenAdMob: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        
        clearCache()
        didShowComplete?()
    }

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
        clearCache()
        didShowComplete?()
    }
}
