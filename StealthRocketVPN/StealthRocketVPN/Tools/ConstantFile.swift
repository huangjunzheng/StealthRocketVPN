//
//  ConstantFile.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import Foundation

// Notification
let OpenLodingProgressDidChangeKey = NSNotification.Name(rawValue: "OpenLodingProgressDidChangeKey")
let SSConnectDurationDidChangeKey = NSNotification.Name(rawValue: "SSConnectDurationDidChangeKey")
let SSConnectStatusDidChangeKey = NSNotification.Name(rawValue: "SSConnectStatusDidChangeKey")



// Enum
enum VPNConnectStatus: Int {
    case connected = 1
    case processing = 2
    case disconnect = 3
}



// Font
let Light = "PingFangSC-Light"      // 细体
let Medium = "PingFangSC-Medium"    // 中黑
let Regular = "PingFangSC-Regular"  // 常规
let Semibold = "PingFangSC-Semibold"// 中粗
let Thin = "PingFangSC-Thin"        // 极细
