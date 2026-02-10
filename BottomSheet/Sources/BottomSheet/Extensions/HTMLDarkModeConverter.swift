//
//  HTMLDarkModeConverter.swift
//  BottomSheet
//
//  Created by 이현재 on 2/10/26.
//

import UIKit

/// HTML 다크모드 변환 유틸리티
/// 서버에서 받은 HTML의 색상값을 다크모드에 맞게 변환합니다.
enum HTMLDarkModeConverter {
    // MARK: - Public Methods

    /// HTML 문자열의 모든 색상을 다크모드용으로 변환
    /// - Parameter html: 원본 HTML 문자열
    /// - Returns: 색상이 변환된 HTML 문자열
    static func convert(_ html: String) -> String {
        var result = html

        // 1. HEX 색상 변환 (#RRGGBB, #RGB)
        result = convertHexColors(in: result)

        // 2. rgb() 색상 변환
        result = convertRGBColors(in: result)

        // 3. rgba() 색상 변환
        result = convertRGBAColors(in: result)

        return result
    }

    // MARK: - Private Methods

    /// HEX 색상 변환 (#RRGGBB, #RGB)
    private static func convertHexColors(in html: String) -> String {
        var result = html

        // #RRGGBB 패턴
        let hex6Pattern = "#([0-9A-Fa-f]{6})(?![0-9A-Fa-f])"
        if let regex = try? NSRegularExpression(pattern: hex6Pattern) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range).reversed()

            for match in matches {
                if let swiftRange = Range(match.range, in: result) {
                    let hexColor = String(result[swiftRange])
                    let darkColor = invertLightness(hex: hexColor)
                    result.replaceSubrange(swiftRange, with: darkColor)
                }
            }
        }

        // #RGB 패턴 (3자리)
        let hex3Pattern = "#([0-9A-Fa-f]{3})(?![0-9A-Fa-f])"
        if let regex = try? NSRegularExpression(pattern: hex3Pattern) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range).reversed()

            for match in matches {
                if let swiftRange = Range(match.range, in: result) {
                    let hexColor = String(result[swiftRange])
                    let expandedHex = expandShortHex(hexColor)
                    let darkColor = invertLightness(hex: expandedHex)
                    result.replaceSubrange(swiftRange, with: darkColor)
                }
            }
        }

        return result
    }

    /// rgb() 색상 변환
    private static func convertRGBColors(in html: String) -> String {
        var result = html

        let rgbPattern = "rgb\\s*\\(\\s*(\\d+)\\s*,\\s*(\\d+)\\s*,\\s*(\\d+)\\s*\\)"
        if let regex = try? NSRegularExpression(pattern: rgbPattern, options: .caseInsensitive) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range).reversed()

            for match in matches {
                guard match.numberOfRanges == 4,
                      let fullRange = Range(match.range, in: result),
                      let rRange = Range(match.range(at: 1), in: result),
                      let gRange = Range(match.range(at: 2), in: result),
                      let bRange = Range(match.range(at: 3), in: result),
                      let r = Int(result[rRange]),
                      let g = Int(result[gRange]),
                      let b = Int(result[bRange]) else { continue }

                let darkColor = invertLightness(r: r, g: g, b: b)
                result.replaceSubrange(fullRange, with: darkColor)
            }
        }

        return result
    }

    /// rgba() 색상 변환
    private static func convertRGBAColors(in html: String) -> String {
        var result = html

        let rgbaPattern = "rgba\\s*\\(\\s*(\\d+)\\s*,\\s*(\\d+)\\s*,\\s*(\\d+)\\s*,\\s*([\\d.]+)\\s*\\)"
        if let regex = try? NSRegularExpression(pattern: rgbaPattern, options: .caseInsensitive) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range).reversed()

            for match in matches {
                guard match.numberOfRanges == 5,
                      let fullRange = Range(match.range, in: result),
                      let rRange = Range(match.range(at: 1), in: result),
                      let gRange = Range(match.range(at: 2), in: result),
                      let bRange = Range(match.range(at: 3), in: result),
                      let aRange = Range(match.range(at: 4), in: result),
                      let r = Int(result[rRange]),
                      let g = Int(result[gRange]),
                      let b = Int(result[bRange]) else { continue }

                let alpha = String(result[aRange])
                let darkColor = invertLightness(r: r, g: g, b: b, alpha: alpha)
                result.replaceSubrange(fullRange, with: darkColor)
            }
        }

        return result
    }

    // MARK: - Color Conversion Helpers

    /// HEX 색상의 명도를 반전
    private static func invertLightness(hex: String) -> String {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6 else { return hex }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Int((rgb & 0xFF0000) >> 16)
        let g = Int((rgb & 0x00FF00) >> 8)
        let b = Int(rgb & 0x0000FF)

        let (newR, newG, newB) = invertLightnessRGB(r: r, g: g, b: b)

        return String(format: "#%02X%02X%02X", newR, newG, newB)
    }

    /// RGB 값의 명도를 반전하고 HEX 문자열 반환
    private static func invertLightness(r: Int, g: Int, b: Int) -> String {
        let (newR, newG, newB) = invertLightnessRGB(r: r, g: g, b: b)
        return String(format: "#%02X%02X%02X", newR, newG, newB)
    }

    /// RGBA 값의 명도를 반전하고 rgba() 문자열 반환
    private static func invertLightness(r: Int, g: Int, b: Int, alpha: String) -> String {
        let (newR, newG, newB) = invertLightnessRGB(r: r, g: g, b: b)
        return "rgba(\(newR), \(newG), \(newB), \(alpha))"
    }

    /// RGB를 HSL로 변환 후 명도 반전하여 RGB로 반환
    private static func invertLightnessRGB(r: Int, g: Int, b: Int) -> (Int, Int, Int) {
        // RGB to HSL
        let rNorm = CGFloat(r) / 255.0
        let gNorm = CGFloat(g) / 255.0
        let bNorm = CGFloat(b) / 255.0

        let maxVal = max(rNorm, gNorm, bNorm)
        let minVal = min(rNorm, gNorm, bNorm)
        let delta = maxVal - minVal

        var h: CGFloat = 0
        var s: CGFloat = 0
        var l = (maxVal + minVal) / 2.0

        if delta != 0 {
            s = l > 0.5 ? delta / (2.0 - maxVal - minVal) : delta / (maxVal + minVal)

            if maxVal == rNorm {
                h = ((gNorm - bNorm) / delta).truncatingRemainder(dividingBy: 6)
            } else if maxVal == gNorm {
                h = (bNorm - rNorm) / delta + 2
            } else {
                h = (rNorm - gNorm) / delta + 4
            }

            h /= 6.0
            if h < 0 { h += 1 }
        }

        // 명도 반전
        l = 1.0 - l

        // HSL to RGB
        func hueToRGB(_ p: CGFloat, _ q: CGFloat, _ t: CGFloat) -> CGFloat {
            var t = t
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1 / 6 { return p + (q - p) * 6 * t }
            if t < 1 / 2 { return q }
            if t < 2 / 3 { return p + (q - p) * (2 / 3 - t) * 6 }
            return p
        }

        var newR: CGFloat, newG: CGFloat, newB: CGFloat

        if s == 0 {
            newR = l
            newG = l
            newB = l
        } else {
            let q = l < 0.5 ? l * (1 + s) : l + s - l * s
            let p = 2 * l - q
            newR = hueToRGB(p, q, h + 1 / 3)
            newG = hueToRGB(p, q, h)
            newB = hueToRGB(p, q, h - 1 / 3)
        }

        return (
            Int(round(newR * 255)),
            Int(round(newG * 255)),
            Int(round(newB * 255)),
        )
    }

    /// 3자리 HEX를 6자리로 확장 (#RGB → #RRGGBB)
    private static func expandShortHex(_ hex: String) -> String {
        var hexSanitized = hex.replacingOccurrences(of: "#", with: "")
        guard hexSanitized.count == 3 else { return hex }

        let chars = Array(hexSanitized)
        hexSanitized = "\(chars[0])\(chars[0])\(chars[1])\(chars[1])\(chars[2])\(chars[2])"

        return "#\(hexSanitized)"
    }
}
