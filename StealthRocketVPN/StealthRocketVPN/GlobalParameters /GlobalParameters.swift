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
    var serverArr = [ServerModel]()
    
    // smart服务器
    var smartArr = [String]()
    
    // 当前选择连接的服务器
    var selectServer: ServerModel?
    
    
    
    // 广告相关
    // 开屏广告id
    var tureAdId = ""
    
    // 首页原生广告id
    var issuAdId = ""
    
    // 结果页原生广告id
    var dormieAdId = ""
    
    // 插屏广告id
    var taskAdId = ""
}
