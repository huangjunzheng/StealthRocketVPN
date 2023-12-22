//
//  ServerCell.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

let ServerCellKey = "ServerCellKey"


class ServerCell: UITableViewCell {
    
    let img = UIImageView()
    
    let titleLab = UILabel()
    
    let selectIcon = UIImageView(image: UIImage(named: "server-disselect"))
    
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = UIColor(hex: "#111417", alpha: 1)
        
        contentView.addSubview(img)
        img.snp.makeConstraints { make in
            
            make.leading.equalTo(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        titleLab.textColor = .white
        titleLab.font = UIFont(name: Semibold, size: 14)
        titleLab.textAlignment = .left
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            
            make.leading.equalTo(img.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(selectIcon)
        selectIcon.snp.makeConstraints { make in
            
            make.trailing.equalTo(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectIcon.image = UIImage(named: selected ? "server-select" : "server-disselect")
    }

}
