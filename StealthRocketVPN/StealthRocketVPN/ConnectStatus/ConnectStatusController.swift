//
//  ConnectStatusController.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/22/23.
//

import UIKit

class ConnectStatusController: UIViewController {
    
    let backImg = UIImageView(image: UIImage(named: "home-discontectback"))
    
    let timeLab = UILabel()
    
    let connectStatusImg = UIImageView()
    
    let countryView = UIView()
    
    let flag = UIImageView()
    
    let name = UILabel()
    
    var didSelectSmart: (() -> Void)?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ResultAdMob.shared.show(vc: self) { isSuccess in
            
            if !isSuccess {
                ResultAdMob.shared.requestAd(complete: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SSConnectDurationDidChange), name: SSConnectDurationDidChangeKey, object: nil)
        
        view.backgroundColor = UIColor(hex: "#111417", alpha: 1)
        navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        
        let backItem = UIBarButtonItem(image: UIImage(named: "back-icon"), style: .done, target: self, action: #selector(backBtn))
        navigationItem.leftBarButtonItem = backItem
        
        view.addSubview(backImg)
        backImg.snp.makeConstraints { make in
            
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(15)
            make.height.equalTo(backImg.snp.width)
        }
        
        timeLab.textColor = .white
        timeLab.font = UIFont(name: Regular, size: 24)
        timeLab.text = "00:00:00"
        view.addSubview(timeLab)
        timeLab.snp.makeConstraints { make in
            
            make.top.equalTo(84)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(connectStatusImg)
        connectStatusImg.snp.makeConstraints { make in
            
            make.top.equalTo(timeLab.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.width.equalTo(172)
            make.height.equalTo(152)
        }
        
        countryView.layer.borderColor = UIColor(hex: "#FFDC30", alpha: 1).cgColor
        countryView.layer.cornerRadius = 16
        countryView.layer.masksToBounds = true
        countryView.backgroundColor = UIColor(hex: "#414549", alpha: 1)
        view.addSubview(countryView)
        countryView.snp.makeConstraints { make in
            
            make.top.equalTo(connectStatusImg.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
            make.width.greaterThanOrEqualTo(200)
        }
        
        flag.contentMode = .scaleAspectFill
        countryView.addSubview(flag)
        flag.snp.makeConstraints { make in
            
            make.leading.top.equalTo(6)
            make.bottom.equalTo(-6)
            make.width.equalTo(flag.snp.height)
        }
        
        name.textAlignment = .left
        name.textColor = .white
        name.font = UIFont(name: Semibold, size: 14)
        countryView.addSubview(name)
        name.snp.makeConstraints { make in
            
            make.centerY.equalToSuperview()
            make.leading.equalTo(flag.snp.trailing).offset(12)
            make.bottom.equalTo(-6)
            make.trailing.equalTo(-6)
        }
        
        let fastBtn = UIButton(type: .custom)
        fastBtn.layer.cornerRadius = 20
        fastBtn.backgroundColor = UIColor(hex: "#1E2124", alpha: 1)
        fastBtn.addTarget(self, action: #selector(fastBtnClick), for: .touchUpInside)
        view.addSubview(fastBtn)
        fastBtn.snp.makeConstraints { make in
            
            make.top.equalTo(countryView.snp.bottom).offset(20)
            make.leading.equalTo(12)
            make.height.equalTo(60)
            make.trailing.equalTo(-12)
        }
        
        let fastImg = UIImageView(image: UIImage(named: "connect-fast"))
        fastBtn.addSubview(fastImg)
        fastImg.snp.makeConstraints { make in
            
            make.leading.equalTo(20)
            make.size.equalTo(CGSize(width: 28, height: 28))
            make.centerY.equalToSuperview()
        }
        
        let fastLab = UILabel()
        fastLab.textColor = .white
        fastLab.font = UIFont(name: Semibold, size: 14)
        fastLab.text = "Accelerate"
        fastBtn.addSubview(fastLab)
        fastLab.snp.makeConstraints { make in
            
            make.centerY.equalToSuperview()
            make.leading.equalTo(fastImg.snp.trailing).offset(12)
        }
        
        let fastIcon = UIImageView(image: UIImage(named: "home-instruct"))
        fastBtn.addSubview(fastIcon)
        fastIcon.snp.makeConstraints { make in
            
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-20)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        update()
    }
    
    func update() {
        
        if SSConnect.shared.status == .connected {
            
            navigationItem.title = NSLocalizedString("Connection Succeed", comment: "")
            connectStatusImg.image = UIImage(named: "connect-on")
        }else if SSConnect.shared.status == .disconnect {
            
            navigationItem.title = NSLocalizedString("Disconnection Succeed", comment: "")
            connectStatusImg.image = UIImage(named: "connect-off")
        }
        if let model = GlobalParameters.shared.selectServer {
            
            name.text = model.ste_bili
            let lowercasedString = model.ste_bili.lowercased()
            let stringWithoutSpaces = lowercasedString.replacingOccurrences(of: " ", with: "")
            flag.image = UIImage(named: stringWithoutSpaces)
        }
    }
    
    @objc func backBtn() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func fastBtnClick() {
        
        if GlobalParameters.shared.smartArr.count > 0 {
            
            let model = GlobalParameters.shared.serverArr.first
            let smartModel = ServerModel()
            smartModel.ste_pisi = model?.ste_pisi ?? ""
            smartModel.ste_tude = model?.ste_tude ?? ""
            smartModel.ste_vagm = model?.ste_vagm ?? ""
            smartModel.ste_bili = "Super Fast Servers"
            smartModel.ste_dicics = "Super Fast Servers"
            smartModel.ste_home = GlobalParameters.shared.smartArr.first ?? ""
            GlobalParameters.shared.selectServer = smartModel
        }
        didSelectSmart?()
        navigationController?.popViewController(animated: true)
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
