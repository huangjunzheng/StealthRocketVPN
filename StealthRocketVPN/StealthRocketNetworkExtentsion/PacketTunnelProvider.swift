//
//  PacketTunnelProvider.swift
//  StealthRocketNetworkExtentsion
//
//  Created by Kuntal Sheth on 12/26/23.
//

import NetworkExtension
import KeychainSwift
import Tun2socks
import Foundation

let Keychain = "KeychainID"
let ExecAppStartAction = "ExecAppStartAction"
let ExecAppStopAction = "ExecAppStopAction"


class PacketTunnelProvider: NEPacketTunnelProvider {
        
    var ss = Shadowsocks()
    
    var startCompletion: ((Error?) -> (Void))?
    
    var stopCompletion: (() -> (Void))?
    
    var isTunnelConnected = false
    

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
        let key = KeychainSwift()
        if let data = key.getData(Keychain),
           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let dic = json as? [String:Any] {
            
            startCompletion = completionHandler
            let model = ConnectModel(dic: dic)
            ss.start(with: model) { [weak self] isSuccess in
                
                guard let self = self else { return }
                if isSuccess {
                    
                    let ipv4 = NEIPv4Settings(addresses: ["192.168.20.1", "10.111.222.0", "169.254.19.0"], subnetMasks: ["255.255.255.0"])
                    ipv4.includedRoutes = [.default()]
                    let ipv6 = NEIPv6Settings(addresses: ["fd66:f83a:c650::1"], networkPrefixLengths: [120])
                    ipv6.includedRoutes = [.default()]
                    let dns = NEDNSSettings(servers: ["208.67.222.222", "8.8.4.4", "1.1.1.1", "216.146.36.36"])
                    let setting = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "192.168.20.1")
                    setting.ipv4Settings = ipv4
                    setting.ipv6Settings = ipv6
                    setting.dnsSettings = dns
                    
                    self.setTunnelNetworkSettings(setting) { [weak self] err in
                        
                        guard let self = self else { return }
                        if err == nil {
                            
                            self.startTun2SocksWithPort(port: 9999)
                            self.execAppCallback(action: ExecAppStartAction, error: err)
                        }else {
                            
                            self.execAppCallback(action: ExecAppStartAction, error: err)
                        }
                        completionHandler(err)
                    }
                }else {
                    
                    self.execAppCallback(action: ExecAppStartAction, error: nil)
                    let err = NSError(domain: NEVPNErrorDomain, code: NEVPNConnectionError.configurationFailed.rawValue)
                    completionHandler(err)
                }
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        
        stopCompletion = completionHandler
        isTunnelConnected = false
        ss.stop { [weak self] in
            
            self?.cancelTunnelWithError(nil)
            self?.execAppCallback(action: ExecAppStopAction, error: nil)
            completionHandler()
        }
    }
}



// 网络连接
extension PacketTunnelProvider: Tun2socksPacketFlowProtocol {
    
    // MARK: - tun2socks
    func writePacket(_ packet: Data!) {
        
        packetFlow.writePackets([packet], withProtocols: [NSNumber(value: AF_INET)])
    }
    
    func startTun2SocksWithPort(port: Int) {
        
        if isTunnelConnected {
            
            execAppCallback(action: ExecAppStartAction, error: nil)
            return
        }
        Tun2socksStartSocks(self, "127.0.0.1", port)
        isTunnelConnected = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                Thread.detachNewThreadSelector(#selector(processInboundPackets), toTarget: self, with: nil)
            }
        }
    }
    
    @objc func processInboundPackets() {
        
        packetFlow.readPackets { packets, protocols in
            
            for pack in packets {
                Tun2socksInputPacket(pack)
            }
            DispatchQueue.main.async { [weak self] in
                
                self?.processInboundPackets()
            }
        }
    }
    
    // MARK: - App IPC
    func execAppCallback(action: String, error: Error?) {
        
        if action == ExecAppStartAction && startCompletion != nil {
            
            startCompletion?(error)
            startCompletion = nil
        }else if action == ExecAppStopAction && stopCompletion != nil {
            
            stopCompletion?()
            stopCompletion = nil
        }
    }
}
