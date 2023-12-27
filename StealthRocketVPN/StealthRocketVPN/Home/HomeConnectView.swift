//
//  HomeConnectView.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

class HomeConnectView: UIView {
    
    let serverBtn = UIButton(type: .custom)
    
    let connectBtn = UIButton(type: .custom)
        
    let switchImg = UIImageView(image: UIImage(named: "home-off"))
    
    let titleLab = UILabel()
        

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 20
        backgroundColor = UIColor(hex: "#1E2124", alpha: 1)
        
        serverBtn.setImage(UIImage(named: "home-server"), for: .normal)
        addSubview(serverBtn)
        serverBtn.snp.makeConstraints { make in
            
            make.leading.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.width.equalTo(serverBtn.snp.height)
        }
        
        connectBtn.backgroundColor = UIColor(hex: "#414549", alpha: 1)
        connectBtn.layer.borderColor = UIColor(hex: "#FFDC30", alpha: 1).cgColor
        connectBtn.layer.cornerRadius = 16
        addSubview(connectBtn)
        connectBtn.snp.makeConstraints { make in
            
            make.top.equalTo(8)
            make.trailing.bottom.equalTo(-8)
            make.leading.equalTo(serverBtn.snp.trailing).offset(8)
        }
        
        let container = UIView()
        connectBtn.addSubview(container)
        container.snp.makeConstraints { make in
            
            make.center.equalToSuperview()
        }
        
        switchImg.isUserInteractionEnabled = true
        container.addSubview(switchImg)
        switchImg.snp.makeConstraints { make in
            
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.leading.centerY.equalToSuperview()
        }
        
        titleLab.text = "Contect"
        titleLab.textColor = .white
        titleLab.font = UIFont(name: Regular, size: 16)
        container.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(switchImg.snp.trailing).offset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setConnect(status: VPNConnectStatus) {
        
        switch status {
        case .connected:
            stopContectingAnimation()
            titleLab.text = "Discontect"
            titleLab.textColor = UIColor(hex: "#FFDC30", alpha: 1)
            switchImg.image = UIImage(named: "home-on")
            connectBtn.layer.borderWidth = 1
            connectBtn.isEnabled = true
                        
        case .processing:
            titleLab.text = "Contecting"
            titleLab.textColor = .white
            switchImg.image = UIImage(named: "home-contecting")
            connectBtn.layer.borderWidth = 0
            startContectingAnimation()
            connectBtn.isEnabled = false
            
        case .disconnect:
            stopContectingAnimation()
            titleLab.text = "Contect"
            titleLab.textColor = .white
            switchImg.image = UIImage(named: "home-off")
            connectBtn.layer.borderWidth = 0
            connectBtn.isEnabled = true
        }
    }
    
    func startContectingAnimation() {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi * 2.0
        rotationAnimation.duration = 0.5
        rotationAnimation.repeatCount = .infinity
        switchImg.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stopContectingAnimation() {
        
        switchImg.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
