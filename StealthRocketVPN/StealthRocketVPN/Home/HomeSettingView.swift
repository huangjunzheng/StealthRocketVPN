//
//  HomeSettingView.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

class HomeSettingView: UIView {
    
    let containerView = UIView()
    
    let contact = SettingItem(title: "Contact Us", icon: "home-contactus")
    
    let privacypolicy = SettingItem(title: "Privacy Policy", icon: "home-privacypolicy")
    
    let update = SettingItem(title: "Update", icon: "home-update")
    
    let share = SettingItem(title: "Share", icon: "home-share")
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        let popBtn = UIButton(type: .custom)
        popBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        addSubview(popBtn)
        popBtn.snp.makeConstraints { make in
            
            make.edges.equalToSuperview()
        }
        
        containerView.backgroundColor = UIColor(hex: "#24272B", alpha: 1)
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            
            make.trailing.equalTo(self.snp.leading)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(300)
        }
        
        let icon = UIImageView(image: UIImage(named: "AppIcon"))
        icon.layer.cornerRadius = 20
        icon.layer.masksToBounds = true
        containerView.addSubview(icon)
        icon.snp.makeConstraints { make in
            
            make.top.equalTo(80)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 72, height: 72))
        }
        
        let nameLab = UILabel()
        nameLab.textColor = .white
        nameLab.font = UIFont(name: Regular, size: 12)
        nameLab.text = "StealthRocketVPN"
        containerView.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            
            make.top.equalTo(icon.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        containerView.addSubview(contact)
        contact.snp.makeConstraints { make in
            
            make.top.equalTo(nameLab.snp.bottom).offset(48)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalTo(64)
        }
        
        containerView.addSubview(privacypolicy)
        privacypolicy.snp.makeConstraints { make in
            
            make.top.equalTo(contact.snp.bottom).offset(8)
            make.leading.trailing.height.equalTo(contact)
        }
        
        containerView.addSubview(update)
        update.snp.makeConstraints { make in
            
            make.top.equalTo(privacypolicy.snp.bottom).offset(8)
            make.leading.trailing.height.equalTo(contact)
        }
        
        containerView.addSubview(share)
        share.snp.makeConstraints { make in
            
            make.top.equalTo(update.snp.bottom).offset(8)
            make.leading.trailing.height.equalTo(contact)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pushView() {
        
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            
            self.backgroundColor = .black.withAlphaComponent(0.4)
            self.containerView.snp.remakeConstraints { make in
                
                make.top.leading.bottom.equalToSuperview()
                make.width.equalTo(300)
            }
            self.layoutIfNeeded()
        }
    }
    
    @objc func popView() {
        
        UIView.animate(withDuration: 0.25) {
            
            self.backgroundColor = .clear
            self.containerView.snp.remakeConstraints { make in
                
                make.trailing.equalTo(self.snp.leading)
                make.top.bottom.equalToSuperview()
                make.width.equalTo(300)
            }
            self.layoutIfNeeded()
        } completion: { complet in
            
            self.removeFromSuperview()
        }
    }
}





class SettingItem: UIButton {
    
    init(title: String, icon: String) {
        super.init(frame: .zero)
        
        let img = UIImageView(image: UIImage(named: icon))
        img.isUserInteractionEnabled = true
        addSubview(img)
        img.snp.makeConstraints { make in
            
            make.leading.equalTo(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        let tagIcon = UIImageView(image: UIImage(named: "home-instruct"))
        addSubview(tagIcon)
        tagIcon.snp.makeConstraints { make in
            
            make.trailing.equalTo(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        let titleLab = UILabel()
        titleLab.textColor = .white
        titleLab.text = title
        titleLab.font = UIFont(name: Regular, size: 16)
        addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            
            make.leading.equalTo(img.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(tagIcon.snp.leading).offset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
