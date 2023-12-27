//
//  HomeAdMob.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/27/23.
//

import UIKit
import GoogleMobileAds

class HomeAdMob: NSObject {

    static let shared = HomeAdMob()
    
    var loadADDate: Date?
    
    var cacheAd: GADNativeAd?
    
    var loader: GADAdLoader?
    
    var adView: GADNativeAdView?
    
    var loadComplete: ((Bool) -> Void)?
    
    // 当前是否正在展示广告
    var isShowing = false
    

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
        
        loadComplete = complete
        loader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511", rootViewController: nil, adTypes: [.native], options: nil)
        if let loader = loader,
           loader.isLoading == false {
            loader.delegate = self
            loader.load(nil)
        }else {
            complete?(false)
        }
    }
    
    func show(vc: UIViewController, complete: ((Bool) -> Void)?) {
        
        if isEffective(),
           let view = setupAdView() {
            
            vc.view.addSubview(view)
            view.snp.makeConstraints { make in
                
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(80)
            }
            complete?(true)
        }else {
            complete?(false)
        }
    }
    
    func setupAdView() -> UIView? {
        
        cacheAd?.delegate = self
        adView = Bundle.main.loadNibNamed("HomeAdView", owner: nil, options: nil)?.first as? GADNativeAdView
        (adView?.headlineView as? UILabel)?.text = cacheAd?.headline
        (adView?.callToActionView as? UIButton)?.setTitle(cacheAd?.callToAction, for: .normal)
        adView?.callToActionView?.isUserInteractionEnabled = false
        (adView?.iconView as? UIImageView)?.image = cacheAd?.icon?.image
        (adView?.bodyView as? UILabel)?.text = cacheAd?.body
        adView?.nativeAd = cacheAd
        return adView
    }
    
    func clearCache() {
        
        cacheAd = nil
        loadADDate = nil
    }
}


// MARK: - 请求广告
extension HomeAdMob: GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        
        cacheAd = nativeAd
        loadADDate = Date()
        loadComplete?(true)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        
        clearCache()
        loadComplete?(false)
    }
}


// MARK: - 广告生命周期
extension HomeAdMob: GADNativeAdDelegate {
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        
        isShowing = true
        clearCache()
        requestAd(complete: nil)
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        
        isShowing = false
    }
}
