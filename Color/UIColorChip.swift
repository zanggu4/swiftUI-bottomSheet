//
//  UIColorChip.swift
//  DesignSystem
//
//  Created by 이현재 on 9/15/25.
//

import UIKit

public enum UIColorChip {
    private static func color(named: String) -> UIColor {
        UIColor(named: "Colors/\(named)", in: .module, compatibleWith: nil)!
    }

    // Gray
    public static var gray0: UIColor { color(named: "gray0") }
    public static var gray10: UIColor { color(named: "gray10") }
    public static var gray15: UIColor { color(named: "gray15") }
    public static var gray20: UIColor { color(named: "gray20") }
    public static var gray30: UIColor { color(named: "gray30") }
    public static var gray40: UIColor { color(named: "gray40") }
    public static var gray50: UIColor { color(named: "gray50") }
    public static var gray60: UIColor { color(named: "gray60") }
    public static var gray70: UIColor { color(named: "gray70") }
    public static var gray80: UIColor { color(named: "gray80") }
    public static var gray85: UIColor { color(named: "gray85") }
    public static var gray90: UIColor { color(named: "gray90") }
    public static var gray100: UIColor { color(named: "gray100") }

    // Pink
    public static var pink5: UIColor { color(named: "pink5") }
    public static var pink10: UIColor { color(named: "pink10") }
    public static var pink20: UIColor { color(named: "pink20") }
    public static var pink30: UIColor { color(named: "pink30") }
    public static var pink40: UIColor { color(named: "pink40") }
    public static var pink50: UIColor { color(named: "pink50") }
    public static var pink60: UIColor { color(named: "pink60") }
    public static var pink70: UIColor { color(named: "pink70") }
    public static var pink80: UIColor { color(named: "pink80") }
    public static var pink90: UIColor { color(named: "pink90") }
    public static var pink95: UIColor { color(named: "pink95") }

    // Yellow
    public static var yellow10: UIColor { color(named: "yellow10") }
    public static var yellow20: UIColor { color(named: "yellow20") }
    public static var yellow30: UIColor { color(named: "yellow30") }
    public static var yellow40: UIColor { color(named: "yellow40") }
    public static var yellow50: UIColor { color(named: "yellow50") }
    public static var yellow60: UIColor { color(named: "yellow60") }
    public static var yellow70: UIColor { color(named: "yellow70") }
    public static var yellow80: UIColor { color(named: "yellow80") }
    public static var yellow90: UIColor { color(named: "yellow90") }

    // Blue
    public static var blue10: UIColor { color(named: "blue10") }
    public static var blue20: UIColor { color(named: "blue20") }
    public static var blue30: UIColor { color(named: "blue30") }
    public static var blue40: UIColor { color(named: "blue40") }
    public static var blue50: UIColor { color(named: "blue50") }
    public static var blue60: UIColor { color(named: "blue60") }
    public static var blue70: UIColor { color(named: "blue70") }
    public static var blue80: UIColor { color(named: "blue80") }
    public static var blue90: UIColor { color(named: "blue90") }

    // Purple
    public static var purple10: UIColor { color(named: "purple10") }
    public static var purple20: UIColor { color(named: "purple20") }
    public static var purple30: UIColor { color(named: "purple30") }
    public static var purple40: UIColor { color(named: "purple40") }
    public static var purple50: UIColor { color(named: "purple50") }
    public static var purple60: UIColor { color(named: "purple60") }
    public static var purple70: UIColor { color(named: "purple70") }
    public static var purple80: UIColor { color(named: "purple80") }
    public static var purple90: UIColor { color(named: "purple90") }

    // Orange
    public static var orange10: UIColor { color(named: "orange10") }
    public static var orange20: UIColor { color(named: "orange20") }
    public static var orange30: UIColor { color(named: "orange30") }
    public static var orange40: UIColor { color(named: "orange40") }
    public static var orange50: UIColor { color(named: "orange50") }
    public static var orange60: UIColor { color(named: "orange60") }
    public static var orange70: UIColor { color(named: "orange70") }
    public static var orange80: UIColor { color(named: "orange80") }
    public static var orange90: UIColor { color(named: "orange90") }

    // Dimmed
    public static var dimmed10: UIColor { color(named: "dimmed10") }
    public static var dimmed15: UIColor { color(named: "dimmed15") }
    public static var dimmed20: UIColor { color(named: "dimmed20") }
    public static var dimmed30: UIColor { color(named: "dimmed30") }
    public static var dimmed40: UIColor { color(named: "dimmed40") }
    public static var dimmed50: UIColor { color(named: "dimmed50") }
    public static var dimmed60: UIColor { color(named: "dimmed60") }
    public static var dimmed70: UIColor { color(named: "dimmed70") }
    public static var dimmed85: UIColor { color(named: "dimmed85") }
    public static var dimmed80: UIColor { color(named: "dimmed80") }
    public static var dimmed90: UIColor { color(named: "dimmed90") }
}
