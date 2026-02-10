//
//  UIColor+Semantic.swift
//  DesignSystem
//
//  Created by 이현재 on 1/2/26.
//

import UIKit

public extension UIColor {
    // MARK: - Private Helper

    private static func dynamic(light: BaseColor, dark: BaseColor) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? dark.uiColor : light.uiColor }
    }

    private static func dynamicHex(light: String, dark: String) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) }
    }

    private static func fixed(_ color: BaseColor) -> UIColor {
        UIColor { _ in color.uiColor }
    }

    private static func fixedHex(_ hex: String) -> UIColor {
        UIColor(hex: hex)
    }

    // MARK: - Bg

    enum Bg {
        public static var benefit: UIColor { fixed(.yellow20) }
        public static var boxButtonBluePressed: UIColor { dynamic(light: .blue20, dark: .blue30) }
        public static var boxButtonBluePrimary: UIColor { dynamic(light: .blue10, dark: .blue20) }
        public static var boxButtonConfirmEnabled: UIColor { fixed(.pink50) }
        public static var boxButtonConfirmPressed: UIColor { dynamic(light: .pink60, dark: .pink40) }
        public static var boxButtonDisabled: UIColor { dynamic(light: .gray20, dark: .gray50) }
        public static var boxButtonKakaoPressed: UIColor { dynamicHex(light: "#F0DB1F", dark: "#F6EA7E") }
        public static var boxButtonOutlinedEnabled: UIColor { dynamic(light: .gray0, dark: .gray100) }
        public static var boxButtonOutlinedPressed: UIColor { dynamic(light: .gray15, dark: .gray85) }
        public static var boxButtonOutlinedPrimary: UIColor { fixedHex("#F3E350") }
        public static var boxButtonPinkEnabled: UIColor { dynamic(light: .pink10, dark: .pink20) }
        public static var boxButtonPinkPressed: UIColor { dynamic(light: .pink20, dark: .pink30) }
        public static var boxButtonPrimaryEnabled: UIColor { dynamic(light: .gray100, dark: .gray10) }
        public static var boxButtonPrimaryPressed: UIColor { dynamic(light: .gray90, dark: .gray20) }
        public static var boxButtonSecondaryEnabled: UIColor { dynamic(light: .gray10, dark: .gray90) }
        public static var boxButtonSecondaryPressed: UIColor { dynamic(light: .gray15, dark: .gray85) }
        public static var critical: UIColor { dynamic(light: .pink10, dark: .pink60) }
        public static var criticalAlt: UIColor { fixed(.pink50) }
        public static var disabled: UIColor { dynamic(light: .gray20, dark: .gray80) }
        public static var focused: UIColor { dynamic(light: .gray100, dark: .gray10) }
        public static var focusedAlt: UIColor { fixed(.pink50) }
        public static var highlighted: UIColor { dynamic(light: .blue10, dark: .blue20) }
        public static var inverse: UIColor { dynamic(light: .gray100, dark: .gray10) }
        public static var layerPrimary: UIColor { fixed(.dimmed50) }
        public static var layerSecondary: UIColor { dynamic(light: .dimmed70, dark: .dimmed10) }
        public static var layerTertiary: UIColor { dynamic(light: .gray0, dark: .gray90) }
        public static var overlayPrimary: UIColor { fixed(.dimmed50) }
        public static var overlaySecondary: UIColor { fixed(.dimmed20) }
        public static var positive: UIColor { dynamic(light: .blue10, dark: .blue20) }
        public static var positiveAlt: UIColor { dynamic(light: .blue60, dark: .blue40) }
        public static var primary: UIColor { dynamic(light: .gray0, dark: .gray100) }
        public static var primaryAlt: UIColor { dynamic(light: .gray0, dark: .gray10) }
        public static var secondary: UIColor { dynamic(light: .gray10, dark: .gray90) }
        public static var thumbnail: UIColor { dynamic(light: .gray20, dark: .gray80) }
        public static var warning: UIColor { dynamic(light: .yellow10, dark: .yellow70) }
    }

    // MARK: - Border

    enum Border {
        public static var benefit: UIColor { dynamic(light: .yellow30, dark: .yellow50) }
        public static var boxButtonOutline: UIColor { dynamic(light: .gray20, dark: .gray80) }
        public static var critical: UIColor { dynamic(light: .pink20, dark: .pink30) }
        public static var disabled: UIColor { dynamic(light: .gray15, dark: .gray85) }
        public static var focused: UIColor { dynamic(light: .gray100, dark: .gray10) }
        public static var focusedAlt: UIColor { fixed(.pink50) }
        public static var inverse: UIColor { dynamic(light: .gray70, dark: .gray30) }
        public static var primary: UIColor { dynamic(light: .gray15, dark: .gray85) }
        public static var secondary: UIColor { dynamic(light: .gray100, dark: .gray10) }
        public static var tertiary: UIColor { dynamic(light: .gray20, dark: .gray80) }
        public static var warning: UIColor { dynamic(light: .yellow30, dark: .yellow40) }
    }

    // MARK: - Icon

    enum Icon {
        public static var benefit: UIColor { fixed(.yellow60) }
        public static var bookmarkActivated: UIColor { fixed(.pink50) }
        public static var bookmarkDefault: UIColor { fixed(.gray70) }
        public static var brand: UIColor { fixed(.pink50) }
        public static var critical: UIColor { fixed(.pink50) }
        public static var disabled: UIColor { dynamic(light: .gray30, dark: .gray70) }
        public static var focused: UIColor { dynamic(light: .gray100, dark: .gray10) }
        public static var focusedAlt: UIColor { fixed(.pink50) }
        public static var highlighted: UIColor { fixed(.blue50) }
        public static var highlightedAlt: UIColor { fixed(.purple50) }
        public static var inverse: UIColor { dynamic(light: .gray0, dark: .gray100) }
        public static var inverseAlt: UIColor { fixed(.gray0) }
        public static var navigationBar: UIColor { dynamic(light: .gray70, dark: .gray30) }
        public static var primary: UIColor { fixed(.gray50) }
        public static var rating: UIColor { fixed(.yellow60) }
        public static var secondary: UIColor { dynamic(light: .gray30, dark: .gray70) }
        public static var secondaryAlt: UIColor { fixed(.gray30) }
        public static var selectBox: UIColor { dynamic(light: .gray40, dark: .gray60) }
        public static var tertiary: UIColor { dynamic(light: .gray20, dark: .gray80) }
    }

    // MARK: - Text

    enum Text {
        public static var benefit: UIColor { fixed(.yellow70) }
        public static var critical: UIColor { fixed(.pink50) }
        public static var criticalAlt: UIColor { dynamic(light: .pink50, dark: .pink10) }
        public static var disabled: UIColor { fixed(.gray40) }
        public static var disabledAlt: UIColor { dynamic(light: .gray30, dark: .gray70) }
        public static var focused: UIColor { dynamic(light: .gray100, dark: .gray10) }
        public static var focusedAlt: UIColor { fixed(.pink50) }
        public static var highlighted: UIColor { fixed(.blue50) }
        public static var highlightedAlt: UIColor { dynamic(light: .blue60, dark: .blue40) }
        public static var inverse: UIColor { dynamic(light: .gray0, dark: .gray100) }
        public static var inverseAlt: UIColor { fixed(.gray0) }
        public static var positive: UIColor { fixed(.blue50) }
        public static var primary: UIColor { dynamic(light: .gray100, dark: .gray10) }
        public static var primaryAlt: UIColor { fixed(.gray100) }
        public static var secondary: UIColor { dynamic(light: .gray70, dark: .gray30) }
        public static var secondaryAlt: UIColor { dynamic(light: .gray80, dark: .gray20) }
        public static var tertiary: UIColor { fixed(.gray50) }
        public static var warning: UIColor { dynamic(light: .yellow80, dark: .yellow20) }
    }
}
