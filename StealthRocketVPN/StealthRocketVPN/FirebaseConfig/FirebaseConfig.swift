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
            return
        }
        globalParameters.tureAdId = json["stl_ture"] as? String ?? ""
        globalParameters.issuAdId = json["stl_issu"] as? String ?? ""
        globalParameters.dormieAdId = json["stl_dormie"] as? String ?? ""
        globalParameters.taskAdId = json["stl_task"] as? String ?? ""
    }
    
    func fetchSmartConfig() {
        
        guard let arr = RemoteConfig.remoteConfig().configValue(forKey: "sta").jsonValue as? [String] else {
            return
        }
        globalParameters.smartArr = arr
    }
    
    func fetchServerConfig() {
        
        guard let json = RemoteConfig.remoteConfig().configValue(forKey: "ste").jsonValue,
              let arr = NSArray.yy_modelArray(with: ServerModel.self, json: json) as? [ServerModel] else {
            return
        }
        globalParameters.serverArr = arr
    }
}
