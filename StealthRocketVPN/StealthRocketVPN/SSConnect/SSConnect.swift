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
    
    var willInBackTime: TimeInterval?
    
        
    func setupConfig() {
        
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
    
    func isVpnConnected() -> Bool {

        let vpnStatus = tunnel.connection.status
        return vpnStatus == .connected || vpnStatus == .connecting || vpnStatus == .reasserting
    }
    
    func startVpn(model: ServerModel) {
        
        connectModel = model
        setTunnelProvider { error in
            
            if let err = error {
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
        
        let session: NETunnelProviderSession = tunnel.connection as! NETunnelProviderSession
        session.stopTunnel()
        tunnel.isOnDemandEnabled = false
        tunnel.saveToPreferences { error in
            // todo
        }
        connectModel = nil
    }
    
    func setTunnelProvider(completion: @escaping(Error?) -> Void) {
        
        NETunnelProviderManager.loadAllFromPreferences() { (managers, error) in
            
            if let error = error {
                return completion(error)
            }
            var manager: NETunnelProviderManager!
            if let managers = managers,
               managers.count > 0 {
                
                manager = managers.first
                let hasOnDemandRules = !(manager?.onDemandRules?.isEmpty ?? true)
                if manager.isEnabled && hasOnDemandRules {
                    self.tunnel = manager
                    return completion(nil)
                }
            } else {
                
                let config = NETunnelProviderProtocol()
                config.providerBundleIdentifier = "c.StealthRocketVPN.StealthRocketNetworkExtentsion"
                manager = NETunnelProviderManager()
                manager.protocolConfiguration = config
            }
            let connectRule = NEOnDemandRuleConnect()
            connectRule.interfaceTypeMatch = .any
            manager.onDemandRules = [connectRule]
            manager.isEnabled = true
            manager.saveToPreferences() { error in
                
                if let error = error {
                    return completion(error)
                }
                self.tunnel = manager
                self.tunnel.loadFromPreferences() { error in
                    completion(error)
                }
            }
        }
    }
    
    func connectFailed() {
        
        connectModel = nil
        cancelTimer()
        NotificationCenter.default.post(name: SSConnectFailedKey, object: nil, userInfo: nil)
    }
    
    func connectDidSuccess() {
        
        startTimer()
        NotificationCenter.default.post(name: SSConnectDidSuccessdKey, object: nil, userInfo: nil)
    }
    
    func connectDidStop() {
        
        cancelTimer()
        NotificationCenter.default.post(name: SSConnectDidStopKey, object: nil, userInfo: nil)
        connectModel = nil
    }
    
    func startTimer() {

        cancelTimer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerDidStart), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func cancelTimer() {

        timer?.invalidate()
        timer = nil
    }

    @objc func timerDidStart() {

        connectDuration += 1
        NotificationCenter.default.post(name: SSConnectDurationDidChangeKey, object: nil, userInfo: ["duration":connectDuration])
    }

    @objc func onBackground() {

        willInBackTime = NSDate().timeIntervalSince1970 - Double(connectDuration)
        cancelTimer()
    }

    @objc func become() {
        
        connectDuration = NSDate().timeIntervalSince1970 - (willInBackTime ?? 0)
        startTimer()
    }
}
