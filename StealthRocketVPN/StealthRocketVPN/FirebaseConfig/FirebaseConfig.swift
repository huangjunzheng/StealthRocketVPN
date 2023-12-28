//
//  FirebaseConfig.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/22/23.
//

import UIKit
import FirebaseRemoteConfig

class FirebaseConfig: NSObject {

    static let shared = FirebaseConfig()
    
    let config = RemoteConfig.remoteConfig()
    
    let globalParameters = GlobalParameters.shared
    
    
    func fetchConfig(complete: ((Bool) -> Void)?) {
        
        RemoteConfig.remoteConfig().fetchAndActivate { [weak self] status, err in
            
            if err != nil {
                complete?(false)
                return
            }
            if status == .successFetchedFromRemote {
                
                self?.fetchAdConfig()
                self?.fetchSmartConfig()
                self?.fetchServerConfig()
                complete?(true)
            }else {
                complete?(false)
            }
        }
    }
    
    func fetchAdConfig() {
        
        guard let json = RemoteConfig.remoteConfig().configValue(forKey: "stl").jsonValue as? [String:Any] else {
            
            if let cacheJson = UserDefaults.standard.dictionary(forKey: CacheRemoteAdkey) {
                globalParameters.tureAdId = cacheJson["stl_ture"] as? String ?? ""
                globalParameters.issuAdId = cacheJson["stl_issu"] as? String ?? ""
                globalParameters.dormieAdId = cacheJson["stl_dormie"] as? String ?? ""
                globalParameters.taskAdId = cacheJson["stl_task"] as? String ?? ""
            }
            return
        }
        
        globalParameters.tureAdId = json["stl_ture"] as? String ?? ""
        globalParameters.issuAdId = json["stl_issu"] as? String ?? ""
        globalParameters.dormieAdId = json["stl_dormie"] as? String ?? ""
        globalParameters.taskAdId = json["stl_task"] as? String ?? ""
        UserDefaults.standard.set(json, forKey: CacheRemoteAdkey)
    }
    
    func fetchSmartConfig() {
        
        guard let arr = RemoteConfig.remoteConfig().configValue(forKey: "sta").jsonValue as? [String] else {
            
            if let cacheArr = UserDefaults.standard.array(forKey: CacheRemoteSmartkey) as? [String] {
                globalParameters.smartArr = cacheArr
            }
            return
        }
        globalParameters.smartArr = arr
        UserDefaults.standard.set(arr, forKey: CacheRemoteSmartkey)
    }
    
    func fetchServerConfig() {
        
//        guard let json = RemoteConfig.remoteConfig().configValue(forKey: "ste").jsonValue,
//              let arr = NSArray.yy_modelArray(with: ServerModel.self, json: json) as? [ServerModel] else {
//            
//            if let cacheArr = UserDefaults.standard.array(forKey: CacheRemoteServerkey) as? [ServerModel] {
//                globalParameters.serverArr = cacheArr
//            }
//            return
//        }
//        globalParameters.serverArr = arr
//        UserDefaults.standard.set(arr, forKey: CacheRemoteServerkey)
        
        
        // test
        let model1 = ServerModel()
        model1.ste_pisi = "OvK5uBRasdPWJGmreUML"
        model1.ste_tude = "chacha20-ietf-poly1305"
        model1.ste_vagm = "5231"
        model1.ste_bili = "Canada"
        model1.ste_home = "137.220.54.94"
        globalParameters.serverArr.append(model1)
        
        let model2 = ServerModel()
        model2.ste_pisi = "OvK5uBRasdPWJGmreUML"
        model2.ste_tude = "chacha20-ietf-poly1305"
        model2.ste_vagm = "5231"
        model2.ste_bili = "United States"
        model2.ste_home = "38.143.66.92"
        globalParameters.serverArr.append(model2)
        
        let model3 = ServerModel()
        model3.ste_pisi = "OvK5uBRasdPWJGmreUML"
        model3.ste_tude = "chacha20-ietf-poly1305"
        model3.ste_vagm = "5231"
        model3.ste_bili = "United States"
        model3.ste_home = "31.13.213.162"
        globalParameters.serverArr.append(model3)
        
        // 添加smart
        if globalParameters.smartArr.count > 0 {
            
            let model = globalParameters.serverArr.first
            let smartModel = ServerModel()
            smartModel.ste_pisi = model?.ste_pisi ?? ""
            smartModel.ste_tude = model?.ste_tude ?? ""
            smartModel.ste_vagm = model?.ste_vagm ?? ""
            smartModel.ste_bili = "Super Fast Servers"
            smartModel.ste_dicics = "Super Fast Servers"
            smartModel.ste_home = globalParameters.smartArr.first ?? ""
            globalParameters.serverArr.insert(smartModel, at: 0)
        }
    }
}
