//
//  ServerController.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

class ServerController: UIViewController, UIGestureRecognizerDelegate {
    
    let tabbleView = UITableView(frame: .zero, style: .grouped)
    
    var serverArr = [ServerModel]()
    
    var didSelect: (() -> Void)?
    
    
    deinit {
        print("ServerController - deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverArr.append(contentsOf: GlobalParameters.shared.serverArr)
        // 添加smart
        if GlobalParameters.shared.smartArr.count > 0 {
            
            let model = GlobalParameters.shared.serverArr.first
            let smartModel = ServerModel()
            smartModel.ste_pisi = model?.ste_pisi ?? ""
            smartModel.ste_tude = model?.ste_tude ?? ""
            smartModel.ste_vagm = model?.ste_vagm ?? ""
            smartModel.ste_bili = "Super Fast Servers"
            smartModel.ste_dicics = "Super Fast Servers"
            smartModel.ste_home = GlobalParameters.shared.smartArr.first ?? ""
            serverArr.insert(smartModel, at: 0)
        }

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
        
        var indexPath = IndexPath(row: 0, section: 0)
        if let selectServer = GlobalParameters.shared.selectServer,
           let index = GlobalParameters.shared.serverArr.firstIndex(of: selectServer) {
            indexPath = IndexPath(row: index, section: 0)
        }
        tabbleView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    @objc func backBtn() {
        
        navigationController?.popViewController(animated: true)
    }
}


extension ServerController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        serverArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ServerCellKey, for: indexPath) as? ServerCell
        let model = serverArr[indexPath.row]
        cell?.titleLab.text = model.ste_bili
        let lowercasedString = model.ste_bili.lowercased()
        let stringWithoutSpaces = lowercasedString.replacingOccurrences(of: " ", with: "")
        cell?.img.image = UIImage(named: stringWithoutSpaces)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        didSelect?()
        GlobalParameters.shared.selectServer = serverArr[indexPath.row]
        // 展示插屏广告
        InterstitialAdMob.shared.show(vc: self) { [weak self] isSuccess in
            
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
