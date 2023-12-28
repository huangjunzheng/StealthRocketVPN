//
//  ServerController.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

class ServerController: UIViewController, UIGestureRecognizerDelegate {
    
    let tabbleView = UITableView(frame: .zero, style: .grouped)
    
    var serverList = GlobalParameters.shared.serverList
    
    var didSelect: (() -> Void)?
    
    
    deinit {
        print("ServerController - deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#111417", alpha: 1)
        navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.title = NSLocalizedString("Change Servers", comment: "")
        
        let backItem = UIBarButtonItem(image: UIImage(named: "back-icon"), style: .done, target: self, action: #selector(backBtn))
        navigationItem.leftBarButtonItem = backItem
        
        tabbleView.backgroundColor = UIColor(hex: "#111417", alpha: 1)
        tabbleView.rowHeight = 60
        tabbleView.dataSource = self
        tabbleView.delegate = self
        tabbleView.separatorStyle = .none
        tabbleView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 12))
        tabbleView.register(ServerCell.self, forCellReuseIdentifier: ServerCellKey)
        view.addSubview(tabbleView)
        tabbleView.snp.makeConstraints { make in
            
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let currentServer = GlobalParameters.shared.currentServer
        let index = GlobalParameters.shared.serverList.firstIndex(of: currentServer) ?? 0
        tabbleView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
    }
    
    @objc func backBtn() {
        
        navigationController?.popViewController(animated: true)
    }
}


extension ServerController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return serverList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ServerCellKey, for: indexPath) as? ServerCell
        let model = serverList[indexPath.row]
        if model.ste_bili == "smart" {
            
            cell?.titleLab.text = "Super Fast Servers"
            cell?.img.image = UIImage(named: "server-smart")
        }else {
            
            cell?.titleLab.text = model.ste_bili
            let lowercasedString = model.ste_bili.lowercased()
            let stringWithoutSpaces = lowercasedString.replacingOccurrences(of: " ", with: "")
            cell?.img.image = UIImage(named: stringWithoutSpaces)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        GlobalParameters.shared.currentServer = serverList[indexPath.row]
        didSelect?()
        // 展示插屏广告
        InterstitialAdMob.shared.show(vc: self) { [weak self] isSuccess in
            
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
