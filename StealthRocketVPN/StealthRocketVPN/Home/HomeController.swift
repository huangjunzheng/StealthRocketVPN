//
//  HomeController.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit
import MessageUI
import AFNetworking

class HomeController: UIViewController {
    
    let backImg = UIImageView(image: UIImage(named: "home-discontectback"))
    
    let connectStatusImg = UIImageView()
    
    let timeLab = UILabel()
    
    let connectView = HomeConnectView()
    
    let download = HomeFlowView(direction: "Download", img: "home-download")
    
    let upload = HomeFlowView(direction: "Upload", img: "home-upload")
    
    let setttingView = HomeSettingView()
    
    let globalParameters = GlobalParameters.shared
    
    let ssConnect = SSConnect.shared
    
    // 是否已经完成插屏广告
    var didShowInterstitialAd = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        HomeAdMob.shared.show(vc: self) { isSuccess in
            
            if !isSuccess {
                HomeAdMob.shared.requestAd(complete: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 如果无网络则推出app
        if AFNetworkReachabilityManager.shared().networkReachabilityStatus == .notReachable || AFNetworkReachabilityManager.shared().networkReachabilityStatus == .unknown {
            
            let alertController = UIAlertController(title: nil, message: "Network request timed out. Please make sure your network is connected", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
        
        if globalParameters.selectServer == nil {
            globalParameters.selectServer = globalParameters.serverArr.first
        }
        NotificationCenter.default.addObserver(self, selector: #selector(SSConnectStatusDidChange), name: SSConnectStatusDidChangeKey, object: nil)
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
            
            make.top.equalTo(48)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(250)
        }
        
        timeLab.textColor = .white
        timeLab.font = UIFont(name: Regular, size: 24)
        timeLab.text = "00:00:00"
        view.addSubview(timeLab)
        timeLab.snp.makeConstraints { make in
            
            make.top.equalTo(connectStatusImg.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        connectView.connectBtn.addTarget(self, action: #selector(connectBtn), for: .touchUpInside)
        connectView.serverBtn.addTarget(self, action: #selector(serverBtn), for: .touchUpInside)
        view.addSubview(connectView)
        connectView.snp.makeConstraints { make in
            
            make.top.equalTo(timeLab.snp.bottom).offset(20)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalTo(76)
        }
        
        view.addSubview(download)
        download.snp.makeConstraints { make in
            
            make.top.equalTo(connectView.snp.bottom).offset(20)
            make.leading.equalTo(12)
            make.trailing.equalTo(view.snp.centerX).offset(-4)
            make.height.equalTo(112)
        }
        
        view.addSubview(upload)
        upload.snp.makeConstraints { make in
            
            make.top.equalTo(connectView.snp.bottom).offset(20)
            make.trailing.equalTo(-12)
            make.leading.equalTo(view.snp.centerX).offset(4)
            make.height.equalTo(112)
        }
        
        updateUI()
    }
    
    func updateUI() {
        
        if ssConnect.status == .connected {
            connectStatusImg.image = UIImage(named: "home-onImg")
        }else {
            connectStatusImg.image = UIImage(named: "home-offImg")
        }
        connectView.setConnect(status: ssConnect.status)
    }
}


// UI点击事件
extension HomeController: MFMailComposeViewControllerDelegate {
    
    @objc func settingBtn() {
        
        setttingView.contact.addTarget(self, action: #selector(setttingContact), for: .touchUpInside)
        setttingView.privacypolicy.addTarget(self, action: #selector(setttingPrivacypolicy), for: .touchUpInside)
        setttingView.update.addTarget(self, action: #selector(setttingUpdate), for: .touchUpInside)
        setttingView.share.addTarget(self, action: #selector(setttingShare), for: .touchUpInside)
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
        
        guard let server = GlobalParameters.shared.selectServer else { return }
        didShowInterstitialAd = false
        if ssConnect.status == .disconnect {
            
            // 连接vpn
            ssConnect.startVpn(model: server)
        }else if ssConnect.status == .connected {
            
            // 断开vpn
            ssConnect.stopVPN()
        }
        updateUI()
        // 请求结果页广告
        ResultAdMob.shared.requestAd(complete: nil)
        // 展示插屏广告
        InterstitialAdMob.shared.show(vc: self) { [weak self] isSuccess in
            
            self?.didShowInterstitialAd = true
            guard let self = self,
                  self.ssConnect.status != .processing else { return }
            
            self.updateUI()
            
            let vc = ConnectStatusController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func setttingContact() {
        
        if MFMailComposeViewController.canSendMail() {

            let email = MFMailComposeViewController()
            email.mailComposeDelegate = self
            email.setToRecipients(["support@stealthrockets.com"])
            present(email, animated: true, completion: nil)
        }
    }
    
    @objc func setttingPrivacypolicy() {
        
        if let url = URL(string: "https://stealthrockets.com/privacy/") {
            let web = BasisWebView()
            web.load(url: url, title: "Privacy Policy")
            present(web, animated: true)
        }
    }
    
    @objc func setttingUpdate() {
        
        if let url = URL(string: "https://stealthrockets.com/terms/") {
            let web = BasisWebView()
            web.load(url: url, title: "Terms")
            present(web, animated: true)
        }
    }
    
    @objc func setttingShare() {
        
        let img = UIImage(named: "launchScreen-icon") ?? UIImage()
        let activityVC = UIActivityViewController(activityItems: ["StealthRocket VPN", img], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    // MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: - VPN回调
extension HomeController {
    
    @objc func SSConnectStatusDidChange(sender: Notification) {
        
        if let data = sender.userInfo?["status"] as? Int,
           let status = VPNConnectStatus(rawValue: data) {
            
            // 插屏广告已经显示，可以显示按钮状态
            if didShowInterstitialAd && status != .processing {
                
                updateUI()
                let vc = ConnectStatusController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func SSConnectDurationDidChange(sender: Notification) {
        
        if let duration = sender.userInfo?["duration"] as? Double {
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.second, .minute, .hour]
            formatter.zeroFormattingBehavior = .pad
            timeLab.text = formatter.string(from: TimeInterval(duration))
        }
    }
}
