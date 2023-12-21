//
//  HomeFlowView.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

class HomeFlowView: UIView {
    
    let countLab = UILabel()
    
    let directionLab = UILabel()
    
    let directionImg = UIImageView()
    
    
    init(direction: String, img: String) {
        super.init(frame: .zero)
        
        layer.cornerRadius = 20
        backgroundColor = UIColor(hex: "#1E2124", alpha: 1)
        
        countLab.textColor = .white
        countLab.text = "0"
        countLab.font = UIFont(name: Regular, size: 20)
        addSubview(countLab)
        countLab.snp.makeConstraints { make in
            
            make.leading.top.equalTo(20)
        }
        
        let unitLab = UILabel()
        unitLab.textColor = UIColor(hex: "#A7A7A7", alpha: 1)
        unitLab.text = "mb"
        unitLab.font = UIFont(name: Regular, size: 14)
        addSubview(unitLab)
        unitLab.snp.makeConstraints { make in
            
            make.leading.equalTo(countLab.snp.trailing).offset(4)
            make.centerY.equalTo(countLab)
        }
        
        directionLab.text = direction
        directionLab.textColor = UIColor(hex: "#A7A7A7", alpha: 1)
        directionLab.font = UIFont(name: Regular, size: 14)
        addSubview(directionLab)
        directionLab.snp.makeConstraints { make in
            
            make.leading.equalTo(20)
            make.bottom.equalTo(-20)
        }
        
        directionImg.image = UIImage(named: img)
        addSubview(directionImg)
        directionImg.snp.makeConstraints { make in
            
            make.leading.equalTo(directionLab.snp.trailing).offset(12)
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.centerY.equalTo(directionLab)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(count: Float) {
        
        
    }
}
