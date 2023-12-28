//
//  GlobalParameters.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/22/23.
//

import UIKit

class GlobalParameters: NSObject {

    static let shared = GlobalParameters()

    // 是否热启动
    var isHotStart = false
    
    // 服务器相关
    // 连接的服务器
    var serverList = [ServerModel]()
    
    // smart服务器
    var smartArr = [String]()
    
    // 当前选择连接的服务器
    var currentServer = ServerModel()

    
    // 广告相关
    // 开屏广告id
    var tureAdId = ""
    
    // 首页原生广告id
    var issuAdId = ""
    
    // 结果页原生广告id
    var dormieAdId = ""
    
    // 插屏广告id
    var taskAdId = ""
    
    
    override init() {
        super.init()
        
        let localServer = """
        [{
          "ste_bili": "smart",
        },
        {
          "ste_pisi": "CvIPfFQ7WKh1OgxNEHXBM",
          "ste_tude": "chacha20-ietf-poly1305",
          "ste_vagm":"5311",
          "ste_bili": "Australia",
          "ste_dicics": "Sydney",
          "ste_home": "103.57.249.116"
        },
        {
          "ste_pisi": "CvIPfFQ7WKh1OgxNEHXBM",
          "ste_tude": "chacha20-ietf-poly1305",
          "ste_vagm":"5311",
          "ste_bili": "United States",
          "ste_dicics": "New York",
          "ste_home": "151.236.22.54"
        },
        {
          "ste_pisi": "CvIPfFQ7WKh1OgxNEHXBM",
          "ste_tude": "chacha20-ietf-poly1305",
          "ste_vagm":"5311",
          "ste_bili": "Japan",
          "ste_dicics": "Tokyo",
          "ste_home": "192.121.162.193"
        }]
        """
        guard let arr = NSArray.yy_modelArray(with: ServerModel.self, json: localServer) as? [ServerModel] else { return }
        serverList.append(contentsOf: arr)
        
        let localSmart = ["151.236.22.54", "192.121.162.193"]
        smartArr.append(contentsOf: localSmart)
        
        // 添加默认连接的服务器
        if let data = UserDefaults.standard.data(forKey: CacheDidConnectServerkey),
           let model = ServerModel.yy_model(withJSON: data) {
            currentServer = model
        }else {
            let smart = ServerModel()
            smart.ste_bili = "smart"
            currentServer = smart
        }
    }
    
    func getSmart() -> ServerModel {
        
        let sm = smartArr.randomElement()
        let model = serverList.first(where: { $0.ste_home == sm })
        return model ?? ServerModel()
    }
    
    
    // 缓存当前连接过的服务器
    func cacheDidConnectServer() {
        
        let model = currentServer.yy_modelToJSONData()
        UserDefaults.standard.set(model, forKey: CacheDidConnectServerkey)
        UserDefaults.standard.synchronize()
    }
}
