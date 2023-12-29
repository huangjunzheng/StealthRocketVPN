//
//  InterstitialAdMob.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/27/23.
//

import UIKit
import GoogleMobileAds

class InterstitialAdMob: NSObject {

    static let shared = InterstitialAdMob()
    
    var loadADDate: Date?
    
    var cacheAd: GADInterstitialAd?
    
    var didShowComplete: ((Bool) -> Void)?
    
    var lodingTimer: Timer?
    
    var count = 0
    
    
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
        
        if isEffective() {
            complete?(true)
            return
        }
        print("[AD] - 插屏广告, 请求广告")
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: nil) { [weak self] ad, err in
            
            guard let self = self,
                  err == nil else {
                self?.clearCache()
                print("[AD] - 插屏广告, 请求失败")
                complete?(false)
                return
            }
            self.cacheAd = ad
            self.loadADDate = Date()
            print("[AD] - 插屏广告, 请求成功")
            complete?(true)
        }
    }
    
    func show(vc: UIViewController, complete: ((Bool) -> Void)?) {
        
        startLodingTimer()
        didShowComplete = complete
        if isEffective() {
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                
                self.cacheAd?.fullScreenContentDelegate = self
                self.cacheAd?.present(fromRootViewController: vc)
            }
        }else {
            
            requestAd { [weak self] isSuccess in
                
                if isSuccess {
                    
                    self?.cacheAd?.fullScreenContentDelegate = self
                    self?.cacheAd?.present(fromRootViewController: vc)
                }else{
                    
                    self?.didShowComplete?(false)
                    self?.didShowComplete = nil
                }
            }
        }
    }
    
    func clearCache() {
        
        cacheAd = nil
        loadADDate = nil
        stopTime()
    }
    
    func startLodingTimer() {
        
        stopTime()
        lodingTimer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
            
            guard let self = self else { return }
            self.count += 1
            if self.count > 10 {
                
                stopTime()
                self.didShowComplete?(false)
                self.didShowComplete = nil
            }
        })
        if let lodingTimer = lodingTimer {
            RunLoop.main.add(lodingTimer, forMode: .common)
        }
    }
    
    func stopTime() {
        
        if let timer = lodingTimer {
            timer.invalidate()
            lodingTimer = nil
            count = 0
        }
    }
}


extension InterstitialAdMob: GADFullScreenContentDelegate {
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        
        print("[AD] - 插屏广告, 展示成功")
        clearCache()
        didShowComplete?(true)
        didShowComplete = nil
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        
        print("[AD] - 插屏广告, 展示失败")
        clearCache()
        didShowComplete?(false)
        didShowComplete = nil
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
        print("[AD] - 插屏广告, 广告关闭")
        clearCache()
        requestAd(complete: nil)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
        print("[AD] - 插屏广告, 广告关闭")
        clearCache()
        requestAd(complete: nil)
    }
}
