//
//  OpenLodingController.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit
import SnapKit

class OpenLodingController: UIViewController {
    
    let progress = UIProgressView()
    
    var lodingTimer: Timer?
    
    var count = 0
    
    
    deinit {
        print("OpenLodingController - deinit")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(progressDidChange), name: OpenLodingProgressDidChangeKey, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#212326", alpha: 1)
        let img = UIImageView(image: UIImage(named: "launchScreen-icon"))
        view.addSubview(img)
        img.snp.makeConstraints { make in
            
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(img.snp.width).priority(600.0/375.0)
        }
        
        progress.progress = 0.5
        progress.layer.cornerRadius = 4
        progress.trackTintColor = UIColor(hex: "#2F3236", alpha: 1)
        progress.progressTintColor = .white
        view.addSubview(progress)
        progress.snp.makeConstraints { make in
            
            make.top.equalTo(img.snp.bottom).offset(52)
            make.size.equalTo(CGSize(width: 80, height: 8))
            make.centerX.equalToSuperview()
        }
        startLodingTimer()
    }
    
    func startLodingTimer() {
        
        stopTime()
        lodingTimer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
            
            guard let self = self else { return }
            self.count += 1
            var expired = 10
            if GlobalParameters.shared.isHotStart {
                expired = 3
            }
            if self.count > expired {
                
                self.pushToHome()
                return
            }
        })
        if let lodingTimer = lodingTimer {
            RunLoop.main.add(lodingTimer, forMode: .common)
        }
    }
    
    func stopTime() {
        
        if let timer = lodingTimer {
            timer.invalidate()
            lodingTimer = nil
            count = 0
        }
    }
    
    func pushToHome() {
        
        stopTime()
        if GlobalParameters.shared.isHotStart {
            
            navigationController?.popViewController(animated: false)
        }else {
            
            let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
            let rootVC = UINavigationController(rootViewController: HomeController())
            window?.rootViewController = rootVC
        }
    }
    
    @objc func progressDidChange(sender: Notification) {
        
        if let progressRate = sender.userInfo?["progress"] as? Float {
            
            print("progressRate: \(progressRate)")
            view.layoutIfNeeded()
            progress.setProgress(progressRate, animated: true)
            
            if progressRate >= 1 { // 全部配置加载完成
                
                stopTime()
                OpenAdMob.shared.show(vc: self) { [weak self] in
                    
                    self?.pushToHome()
                }
            }
        }
    }
}
