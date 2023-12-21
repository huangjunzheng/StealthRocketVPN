//
//  HomeController.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

class HomeController: UIViewController {
    
    let connectStatusImg = UIImageView(image: UIImage(named: "home-offImg"))
    
    let timeLab = UILabel()
    
    let connectView = HomeConnectView()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        
        view.backgroundColor = UIColor(hex: "#111417", alpha: 1)
        
        let settingItem = UIBarButtonItem(image: UIImage(named: "home-setting"), style: .done, target: self, action: #selector(settingBtn))
        navigationItem.leftBarButtonItem = settingItem
        
        let backImg = UIImageView(image: UIImage(named: "home-backcolor"))
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
        
        connectView.connectBtn.addTarget(self, action: #selector(connectBtn), for: .touchUpInside)
        connectView.serverBtn.addTarget(self, action: #selector(serverBtn), for: .touchUpInside)
        view.addSubview(connectView)
        connectView.snp.makeConstraints { make in
            
            make.top.equalTo(timeLab.snp.bottom).offset(28)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalTo(76)
        }
    }
}


extension HomeController {
    
    @objc func settingBtn() {
        
        
    }
    
    @objc func serverBtn() {
        
        
    }
    
    @objc func connectBtn() {
        
        print("connectBtn")
    }
}
