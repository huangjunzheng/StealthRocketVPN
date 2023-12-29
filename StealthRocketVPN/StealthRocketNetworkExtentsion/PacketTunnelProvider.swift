//
//  PacketTunnelProvider.swift
//  StealthRocketNetworkExtentsion
//
//  Created by Kuntal Sheth on 12/26/23.
//

import NetworkExtension
import KeychainSwift
import Tun2socks
import MMWormhole

let ExecAppStartAction = "ExecAppStartAction"
let ExecAppStopAction = "ExecAppStopAction"
let VPNStateNotify = "VPNStateNotify"
let VPNConnectErrorNotify = "VPNConnectErrorNotify"


class PacketTunnelProvider: NEPacketTunnelProvider {
            
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.c.StealthRocketVPN", optionalDirectory: nil)
    
    var startCompletion: ((Error?) -> (Void))?
    
    var stopCompletion: (() -> (Void))?
        
    var tunnel: Tun2socksTunnelProtocol?
    
    var packetQueue = DispatchQueue(label: "com.StealthRocketVPN.packetqueue")
    


    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
        NSLog("extentsion - startTunnel")
        let key = KeychainSwift()
        if let data = key.getData("KeychainID"),
           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let dic = json as? [String:Any] {
            
            NSLog("extentsion - startTunnel dic:\(dic)")
            startCompletion = completionHandler
            guard let ip = dic["ip"] as? String,
                  let port = dic["port"] as? String,
                  let password = dic["password"] as? String,
                  let cipherName = dic["encrypProtocol"] as? String else {
                self.execAppCallback(isStart: true, error: nil)
                wormhole.passMessageObject(nil, identifier: VPNConnectErrorNotify)
                return
            }

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
                
                NSLog("extentsion - setTunnelNetworkSettings err:\(String(describing: err))")
                guard let self = self else { return }
                if let err = err {
                    self.execAppCallback(isStart: true, error: err)
                    wormhole.passMessageObject(NSDictionary(dictionary: ["error" : err]), identifier: VPNConnectErrorNotify)
                }else {

                    let config = ShadowsocksConfig()
                    config.host = ip
                    config.port = Int(port) ?? 0
                    config.password = password
                    config.cipherName = cipherName
                    guard let client = ShadowsocksNewClient(config, nil) else { return }
                    tunnel = Tun2socksConnectShadowsocksTunnel(self, client, false, nil)
                    packetQueue.async { [weak self] in
                                        
                        self?.processPackets()
                    }
                    self.execAppCallback(isStart: true, error: nil)
                    wormhole.passMessageObject(NSDictionary(dictionary: ["VPNState" : 1]), identifier: VPNStateNotify)
                }
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        
        NSLog("extentsion - stopTunnel")
        wormhole.passMessageObject(NSDictionary(dictionary: ["VPNState" : 0]), identifier: VPNStateNotify)
        self.tunnel?.disconnect()
        stopCompletion = completionHandler
    }
    
    func processPackets() {
        
        NSLog("extentsion - processPackets")
        var pointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        packetFlow.readPackets(completionHandler: { [weak self] packets, protocols in
            
            for packet in packets {
                let _ = try? self?.tunnel?.write(packet, ret0_: pointer)
            }
            self?.packetQueue.async { [weak self] in
                self?.processPackets()
            }
        })
    }
    
    // MARK: - App IPC
    func execAppCallback(isStart: Bool, error: Error?) {
        
        NSLog("extentsion - execAppCallback isStart: \(isStart), error: \(String(describing: error))")
        if isStart == true && startCompletion != nil {
            
            startCompletion?(error)
            startCompletion = nil
        }else if isStart == false && stopCompletion != nil {
            
            stopCompletion?()
            stopCompletion = nil
        }
    }
}


extension PacketTunnelProvider: Tun2socksTunWriterProtocol {
    
    func close() throws {
    }
    
    func write(_ p0: Data?, n: UnsafeMutablePointer<Int>?) throws {
        
        if let p0 = p0 {
            packetFlow.writePackets([p0], withProtocols: [NSNumber(value: AF_INET)])
        }
    }
}
