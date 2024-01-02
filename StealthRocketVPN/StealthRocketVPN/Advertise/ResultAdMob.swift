//
//  ResultAdMob.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/27/23.
//

import UIKit
import GoogleMobileAds

class ResultAdMob: NSObject {

    static let shared = ResultAdMob()
    
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
        
        if isEffective() {
            complete?(true)
            return
        }
        loadComplete = complete
        loader = GADAdLoader(adUnitID: GlobalParameters.shared.dormieAdId, rootViewController: nil, adTypes: [.native], options: nil)
        if let loader = loader,
           loader.isLoading == false {
            print("[AD] - 结果原生, 请求广告")
            loader.delegate = self
            loader.load(nil)
        }else {
            print("[AD] - 结果原生, 请求失败")
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
            print("[AD] - 结果原生, 展示失败")
            complete?(false)
        }
    }
    
    func setupAdView() -> UIView? {
        
        cacheAd?.delegate = self
        adView = Bundle.main.loadNibNamed("ResultAdView", owner: nil, options: nil)?.first as? GADNativeAdView
        (adView?.headlineView as? UILabel)?.text = cacheAd?.headline
        (adView?.callToActionView as? UIButton)?.setTitle(cacheAd?.callToAction, for: .normal)
        adView?.callToActionView?.isUserInteractionEnabled = false
        (adView?.iconView as? UIImageView)?.image = cacheAd?.icon?.image
        (adView?.bodyView as? UILabel)?.text = cacheAd?.body
        adView?.mediaView?.mediaContent = cacheAd?.mediaContent
        adView?.nativeAd = cacheAd
        return adView
    }
    
    func clearCache() {
        
        cacheAd = nil
        loadADDate = nil
    }
}


// MARK: - 请求广告
extension ResultAdMob: GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        
        print("[AD] - 结果原生, 请求成功")
        cacheAd = nativeAd
        loadADDate = Date()
        loadComplete?(true)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        
        print("[AD] - 结果原生, 请求失败")
        clearCache()
        loadComplete?(false)
    }
}


// MARK: - 广告生命周期
extension ResultAdMob: GADNativeAdDelegate {
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        
        print("[AD] - 结果原生, 展示成功")
        isShowing = true
        clearCache()
        requestAd(complete: nil)
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        
        isShowing = false
    }
}
