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
    
    let connectStatusImg = UIImageView(image: UIImage(named: "connect-on"))
    
    let countryView = UIView()
    
    let flag = UIImageView()
    
    let name = UILabel()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#111417", alpha: 1)
        navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        navigationItem.title = NSLocalizedString("Connection Succeed", comment: "")
        
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
            
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(84)
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
        
        countryView.addSubview(flag)
        flag.snp.makeConstraints { make in
            
            make.centerY.equalToSuperview()
            make.leading.top.equalTo(6)
            make.bottom.equalTo(-6)
        }
        
        name.textAlignment = .left
        name.textColor = .white
        name.font = UIFont(name: Semibold, size: 20)
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
            make.trailing.equalTo(20)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
    }
    
    @objc func backBtn() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func fastBtnClick() {
        
        navigationController?.popViewController(animated: true)
    }
}
