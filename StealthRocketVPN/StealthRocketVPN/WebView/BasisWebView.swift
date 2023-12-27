//
//  BasisWebView.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/27/23.
//

import UIKit
import WebKit

class BasisWebView: UIViewController {
    
    let web = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        view.backgroundColor = .white
        let backItem = UIBarButtonItem(image: UIImage(named: "back-icon"), style: .done, target: self, action: #selector(backBtn))
        navigationItem.leftBarButtonItem = backItem

        view.addSubview(web)
        web.snp.makeConstraints({ make in

            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        })
    }
    
    func load(url: URL, title: String?) {

        navigationItem.title = title
        web.load(URLRequest(url: url))
    }

    @objc func backBtn() {

        navigationController?.popViewController(animated: true)
    }
}
