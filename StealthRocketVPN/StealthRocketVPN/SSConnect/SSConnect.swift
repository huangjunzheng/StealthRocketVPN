//
//  SSConnect.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/26/23.
//

import UIKit
import NetworkExtension
import MMWormhole
import KeychainSwift


class SSConnect: NSObject {

    static let shared = SSConnect()
    
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.c.StealthRocketVPN", optionalDirectory: nil)
    
    var tunnel = NETunnelProviderManager()
    
    var connectModel: ServerModel?
    
    var timer: Timer?
    
    var connectDuration: Double = 0
    
    var tagTime: TimeInterval?
    
    var status: VPNConnectStatus = .disconnect
    
        
    func setupConfig() {
        
        tunnel.loadFromPreferences { error in
            
            if error != nil {
                return
            }
            let vpnStatus = self.tunnel.connection.status
            if vpnStatus == .connected {
                self.status = .connected
            }else if vpnStatus == .connecting || vpnStatus == .reasserting || vpnStatus == .disconnecting {
                self.status = .processing
            }else {
                self.status = .disconnect
            }
            NotificationCenter.default.post(name: SSConnectStatusDidChangeKey, object: nil, userInfo: ["status": self.status.rawValue])
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(become), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        wormhole.listenForMessage(withIdentifier: "VPNStateNotify") { [weak self] data in
            
            if let dic = data as? NSDictionary,
               let state = dic["VPNState"] as? Int {
                
                if state == 0 {
                    self?.connectDidStop()
                }else {
                    self?.connectDidSuccess()
                }
            }
        }
        
        wormhole.listenForMessage(withIdentifier: "VPNConnectErrorNotify") { [weak self] data in

            self?.connectFailed()
        }
    }

    func startVpn(model: ServerModel) {
        
        status = .processing
        NotificationCenter.default.post(name: SSConnectStatusDidChangeKey, object: nil, userInfo: ["status": status.rawValue])
        connectModel = model
        setTunnelProvider { error in
            
            if error != nil {
                self.connectFailed()
                return
            }
            let dic = [
                "ip": model.ste_home,
                "port": model.ste_vagm,
                "password": model.ste_pisi,
                "encrypProtocol": model.ste_tude,
            ] as [String:Any]
            
            do {
                let data = try JSONSerialization.data(withJSONObject: dic)
                let key = KeychainSwift()
                key.accessGroup = "group.c.StealthRocketVPN"
                key.set(data, forKey: "KeychainID")
                try self.tunnel.connection.startVPNTunnel()
            } catch {
                self.connectFailed()
            }
        }
    }
    
    func stopVPN() {
        
        status = .processing
        NotificationCenter.default.post(name: SSConnectStatusDidChangeKey, object: nil, userInfo: ["status": status.rawValue])
        let session: NETunnelProviderSession = tunnel.connection as! NETunnelProviderSession
        session.stopTunnel()
        tunnel.isOnDemandEnabled = false
        tunnel.saveToPreferences { error in
            if error != nil {
                self.connectFailed()
            }
        }
        connectModel = nil
    }

    func setTunnelProvider(completion: @escaping(Error?) -> Void) {
        
        NETunnelProviderManager.loadAllFromPreferences() { (managers, error) in
                        
            if let error = error {
                self.connectFailed()
                completion(error)
                return
            }
            
            if let manager = managers?.first {
                                
                self.tunnel = manager
                self.tunnel.loadFromPreferences(completionHandler: completion)
            }else {
                
                let config = NETunnelProviderProtocol()
                config.serverAddress = ""
                config.providerBundleIdentifier = "com.stealth.rocket.secure.high.speed.link.StealthRocketNetworkExtentsion"
                self.tunnel.protocolConfiguration = config
                self.tunnel.isEnabled = true
                self.tunnel.saveToPreferences(completionHandler: { [weak self] error in
                    
                    if let error = error {
                        self?.connectFailed()
                        completion(error)
                        return
                    }
                    self?.tunnel.loadFromPreferences(completionHandler: completion)
                })
            }
        }
    }
    
    func connectFailed() {
        
        status = .disconnect
        connectModel = nil
        stopTimer()
        NotificationCenter.default.post(name: SSConnectStatusDidChangeKey, object: nil, userInfo: ["status": status.rawValue])
    }
    
    func connectDidSuccess() {
        
        status = .connected
        tagTime = Date().timeIntervalSince1970
        connectDuration = 0
        openTimer()
        // 连接成功时缓存当前服务器
        GlobalParameters.shared.cacheDidConnectServer()
        NotificationCenter.default.post(name: SSConnectStatusDidChangeKey, object: nil, userInfo: ["status": status.rawValue])
    }
    
    func connectDidStop() {
        
        status = .disconnect
        stopTimer()
        NotificationCenter.default.post(name: SSConnectStatusDidChangeKey, object: nil, userInfo: ["status": status.rawValue])
        connectModel = nil
    }
    
    func openTimer() {

        stopTimer()
        if status == .processing { return }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerDidStart), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopTimer() {

        timer?.invalidate()
        timer = nil
    }

    @objc func timerDidStart() {

        connectDuration += 1
        NotificationCenter.default.post(name: SSConnectDurationDidChangeKey, object: nil, userInfo: ["duration":connectDuration])
    }

    @objc func onBackground() {

        // 进入后台前，保存当前连接的时长
        tagTime = NSDate().timeIntervalSince1970 - Double(connectDuration)
        stopTimer()
    }

    @objc func become() {
        
        // 返回app时，更新连接市场
        if status == .connected {
            connectDuration = NSDate().timeIntervalSince1970 - (tagTime ?? 0)
            openTimer()
        }
    }
}
