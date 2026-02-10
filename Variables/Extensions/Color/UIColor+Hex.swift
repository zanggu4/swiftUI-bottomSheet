//
//  UIColor+Hex.swift
//  DesignSystem
//
//  Created by 이현재 on 1/15/26.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        // #이 포함되어 있는 경우 #제거
        let newHex = hex.replacingOccurrences(of: "#", with: "", options: NSString.CompareOptions.literal, range: nil)
        let scanner = Scanner(string: newHex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0xFF00) >> 8
        let b = rgbValue & 0xFF

        self.init(
            red: CGFloat(r) / 0xFF,
            green: CGFloat(g) / 0xFF,
            blue: CGFloat(b) / 0xFF, alpha: 1,
        )
    }

    var hexString: String {
        let components = cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
}
