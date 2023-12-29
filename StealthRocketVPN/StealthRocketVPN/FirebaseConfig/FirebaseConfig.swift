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
        
        config.fetchAndActivate { [weak self] status, err in
            
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
        
        
        guard let json = try? JSONSerialization.jsonObject(with: config.configValue(forKey: "stl").dataValue) as? [String:Any] else {
            
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
        
        guard let arr = config.configValue(forKey: "sta").jsonValue as? [String] else {
            
            if let cacheArr = UserDefaults.standard.array(forKey: CacheRemoteSmartkey) as? [String] {
                globalParameters.smartArr = cacheArr
            }
            return
        }
        globalParameters.smartArr = arr
        UserDefaults.standard.set(arr, forKey: CacheRemoteSmartkey)
    }
    
    func fetchServerConfig() {
        
        guard let json = config.configValue(forKey: "ste").jsonValue,
              let arr = NSArray.yy_modelArray(with: ServerModel.self, json: json) as? [ServerModel] else {
            
            if let cacheJson = UserDefaults.standard.value(forKey: CacheRemoteServerkey),
               let cacheArr = NSArray.yy_modelArray(with: ServerModel.self, json: cacheJson) as? [ServerModel] {
                
                globalParameters.serverList = cacheArr
                let smart = ServerModel()
                smart.ste_bili = "smart"
                globalParameters.serverList.insert(smart, at: 0)
            }
            return
        }
        globalParameters.serverList = arr
        let smart = ServerModel()
        smart.ste_bili = "smart"
        globalParameters.serverList.insert(smart, at: 0)
        UserDefaults.standard.set(json, forKey: CacheRemoteServerkey)
    }
}
