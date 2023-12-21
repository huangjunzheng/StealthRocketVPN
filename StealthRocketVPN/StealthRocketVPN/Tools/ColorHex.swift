//
//  ColorHex.swift
//  StealthRocketVPN
//
//  Created by Kuntal Sheth on 12/21/23.
//

import UIKit

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat) {

        var r: UInt64 = 0
        var g: UInt64 = 0
        var b: UInt64 = 0
        var hexTemp = hex
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hexTemp = String(hexTemp[hexTemp.index(hexTemp.startIndex, offsetBy: 2)...])
        } else if hex.hasPrefix("#") {
            hexTemp = String(hexTemp[hexTemp.index(hexTemp.startIndex, offsetBy: 1)...])
        }
        if hexTemp.count < 6 {
           for _ in 0..<6-hexTemp.count {
               hexTemp += "0"
           }
        }
        Scanner(string: String(hexTemp[..<hexTemp.index(hexTemp.startIndex, offsetBy: 2)])).scanHexInt64(&r)
        Scanner(string: String(hexTemp[hexTemp.index(hexTemp.startIndex, offsetBy: 2)..<hexTemp.index(hexTemp.startIndex, offsetBy: 4)])).scanHexInt64(&g)
        Scanner(string: String(hexTemp[hexTemp.index(hexTemp.startIndex, offsetBy: 4)...])).scanHexInt64(&b)
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
}
