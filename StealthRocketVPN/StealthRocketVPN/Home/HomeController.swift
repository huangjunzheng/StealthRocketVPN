//
//  HomeController.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

class HomeController: UIViewController {
    
    let backImg = UIImageView(image: UIImage(named: "home-discontectback"))
    
    let connectStatusImg = UIImageView(image: UIImage(named: "home-offImg"))
    
    let timeLab = UILabel()
    
    let connectView = HomeConnectView()
    
    let download = HomeFlowView(direction: "Download", img: "home-download")
    
    let upload = HomeFlowView(direction: "Upload", img: "home-upload")
    
    let setttingView = HomeSettingView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(SSConnectDidSuccessd), name: SSConnectDidSuccessdKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SSConnectDidStop), name: SSConnectDidStopKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SSConnectFailed), name: SSConnectFailedKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SSConnectDurationDidChange), name: SSConnectDurationDidChangeKey, object: nil)
        setupView()
    }
    
    func setupView() {
        
        view.backgroundColor = UIColor(hex: "#111417", alpha: 1)
        
        let settingItem = UIBarButtonItem(image: UIImage(named: "home-setting"), style: .done, target: self, action: #selector(settingBtn))
        navigationItem.leftBarButtonItem = settingItem
        
        view.addSubview(backImg)
        backImg.snp.makeConstraints { make in
            
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(15)
            make.height.equalTo(backImg.snp.width)
        }
        
        view.addSubview(connectStatusImg)
        connectStatusImg.snp.makeConstraints { make in
            
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(48)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(260)
        }
        
        timeLab.textColor = .white
        timeLab.font = UIFont(name: Regular, size: 24)
        timeLab.text = "00:00:00"
        view.addSubview(timeLab)
        timeLab.snp.makeConstraints { make in
            
            make.top.equalTo(connectStatusImg.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
                
        if SSConnect.shared.isVpnConnected() {
            connectView.setConnect(status: .connect)
        }else {
            connectView.setConnect(status: .disconnect)
        }
        connectView.connectBtn.addTarget(self, action: #selector(connectBtn), for: .touchUpInside)
        connectView.serverBtn.addTarget(self, action: #selector(serverBtn), for: .touchUpInside)
        view.addSubview(connectView)
        connectView.snp.makeConstraints { make in
            
            make.top.equalTo(timeLab.snp.bottom).offset(28)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalTo(76)
        }
        
        view.addSubview(download)
        download.snp.makeConstraints { make in
            
            make.top.equalTo(connectView.snp.bottom).offset(20)
            make.leading.equalTo(12)
            make.trailing.equalTo(view.snp.centerX).offset(-4)
            make.height.equalTo(138)
        }
        
        view.addSubview(upload)
        upload.snp.makeConstraints { make in
            
            make.top.equalTo(connectView.snp.bottom).offset(20)
            make.trailing.equalTo(-12)
            make.leading.equalTo(view.snp.centerX).offset(4)
            make.height.equalTo(138)
        }
    }
}


// UI点击事件
extension HomeController {
    
    @objc func settingBtn() {
        
        navigationController?.view.addSubview(setttingView)
        setttingView.snp.makeConstraints { make in
            
            make.edges.equalToSuperview()
        }
        setttingView.pushView()
    }
    
    @objc func serverBtn() {
        
        let serverVC = ServerController()
        navigationController?.pushViewController(serverVC, animated: true)
    }
    
    @objc func connectBtn() {
                
        if let server = GlobalParameters.shared.selectServer,
           SSConnect.shared.isVpnConnected() == false {
            
            connectView.setConnect(status: .connecting)
            SSConnect.shared.startVpn(model: server)
        }
    }
}


// MARK: - VPN回调
extension HomeController {
    
    @objc func SSConnectDidSuccessd() {
        
        connectView.setConnect(status: .connect)
        print("vpn - SSConnectDidSuccessd")
    }
    
    @objc func SSConnectDidStop() {
        
        connectView.setConnect(status: .disconnect)
        print("vpn - SSConnectDidStop")
    }
    
    @objc func SSConnectFailed() {
                
        connectView.setConnect(status: .disconnect)
        print("vpn - SSConnectFailed")
    }
    
    @objc func SSConnectDurationDidChange() {
                
        print("vpn - SSConnectDurationDidChange")
    }
}
