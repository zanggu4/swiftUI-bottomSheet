
//
//  Number+Utilities.swift
//  Foundation
//
//  Created by 이현재 on 8/28/25.
//

import CoreGraphics
import Foundation

// MARK: - Int

public extension Int {
    var util: IntUtilWrapper { IntUtilWrapper(self) }
}

public struct IntUtilWrapper {
    let base: Int
    fileprivate init(_ base: Int) { self.base = base }
}

public extension IntUtilWrapper {
    /// 천자리당 콤마가 표시된 문자열
    var withCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        return numberFormatter.string(from: NSNumber(value: base))!
    }
}

// MARK: - Double

public extension Double {
    var util: DoubleUtilWrapper { DoubleUtilWrapper(self) }
}

public struct DoubleUtilWrapper {
    let base: Double
    fileprivate init(_ base: Double) { self.base = base }
}

public extension DoubleUtilWrapper {
    func withCommas(fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(floatLiteral: base)) ?? "\(base)"
    }
}

// MARK: - CGFloat

public extension CGFloat {
    var util: CGFloatUtilWrapper { CGFloatUtilWrapper(self) }
}

public struct CGFloatUtilWrapper {
    let base: CGFloat
    fileprivate init(_ base: CGFloat) { self.base = base }
}

public extension CGFloatUtilWrapper {
    func withCommas(fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(floatLiteral: base)) ?? "\(base)"
    }
}
