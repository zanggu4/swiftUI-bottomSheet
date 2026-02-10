//
//  Color+Semantic.swift
//  DesignSystem
//
//  Created by 이현재 on 1/2/26.
//

import SwiftUI
import UIKit

public extension Color {
    // MARK: - Bg

    enum Bg {
        public static var benefit: Color { Color(UIColor.Bg.benefit) }
        public static var boxButtonBluePressed: Color { Color(UIColor.Bg.boxButtonBluePressed) }
        public static var boxButtonBluePrimary: Color { Color(UIColor.Bg.boxButtonBluePrimary) }
        public static var boxButtonConfirmEnabled: Color { Color(UIColor.Bg.boxButtonConfirmEnabled) }
        public static var boxButtonConfirmPressed: Color { Color(UIColor.Bg.boxButtonConfirmPressed) }
        public static var boxButtonDisabled: Color { Color(UIColor.Bg.boxButtonDisabled) }
        public static var boxButtonKakaoPressed: Color { Color(UIColor.Bg.boxButtonKakaoPressed) }
        public static var boxButtonOutlinedEnabled: Color { Color(UIColor.Bg.boxButtonOutlinedEnabled) }
        public static var boxButtonOutlinedPressed: Color { Color(UIColor.Bg.boxButtonOutlinedPressed) }
        public static var boxButtonOutlinedPrimary: Color { Color(UIColor.Bg.boxButtonOutlinedPrimary) }
        public static var boxButtonPinkEnabled: Color { Color(UIColor.Bg.boxButtonPinkEnabled) }
        public static var boxButtonPinkPressed: Color { Color(UIColor.Bg.boxButtonPinkPressed) }
        public static var boxButtonPrimaryEnabled: Color { Color(UIColor.Bg.boxButtonPrimaryEnabled) }
        public static var boxButtonPrimaryPressed: Color { Color(UIColor.Bg.boxButtonPrimaryPressed) }
        public static var boxButtonSecondaryEnabled: Color { Color(UIColor.Bg.boxButtonSecondaryEnabled) }
        public static var boxButtonSecondaryPressed: Color { Color(UIColor.Bg.boxButtonSecondaryPressed) }
        public static var critical: Color { Color(UIColor.Bg.critical) }
        public static var criticalAlt: Color { Color(UIColor.Bg.criticalAlt) }
        public static var disabled: Color { Color(UIColor.Bg.disabled) }
        public static var focused: Color { Color(UIColor.Bg.focused) }
        public static var focusedAlt: Color { Color(UIColor.Bg.focusedAlt) }
        public static var highlighted: Color { Color(UIColor.Bg.highlighted) }
        public static var inverse: Color { Color(UIColor.Bg.inverse) }
        public static var layerPrimary: Color { Color(UIColor.Bg.layerPrimary) }
        public static var layerSecondary: Color { Color(UIColor.Bg.layerSecondary) }
        public static var layerTertiary: Color { Color(UIColor.Bg.layerTertiary) }
        public static var overlayPrimary: Color { Color(UIColor.Bg.overlayPrimary) }
        public static var overlaySecondary: Color { Color(UIColor.Bg.overlaySecondary) }
        public static var positive: Color { Color(UIColor.Bg.positive) }
        public static var positiveAlt: Color { Color(UIColor.Bg.positiveAlt) }
        public static var primary: Color { Color(UIColor.Bg.primary) }
        public static var primaryAlt: Color { Color(UIColor.Bg.primaryAlt) }
        public static var secondary: Color { Color(UIColor.Bg.secondary) }
        public static var thumbnail: Color { Color(UIColor.Bg.thumbnail) }
        public static var warning: Color { Color(UIColor.Bg.warning) }
    }

    // MARK: - Border

    enum Border {
        public static var benefit: Color { Color(UIColor.Border.benefit) }
        public static var boxButtonOutline: Color { Color(UIColor.Border.boxButtonOutline) }
        public static var critical: Color { Color(UIColor.Border.critical) }
        public static var disabled: Color { Color(UIColor.Border.disabled) }
        public static var focused: Color { Color(UIColor.Border.focused) }
        public static var focusedAlt: Color { Color(UIColor.Border.focusedAlt) }
        public static var inverse: Color { Color(UIColor.Border.inverse) }
        public static var primary: Color { Color(UIColor.Border.primary) }
        public static var secondary: Color { Color(UIColor.Border.secondary) }
        public static var tertiary: Color { Color(UIColor.Border.tertiary) }
        public static var warning: Color { Color(UIColor.Border.warning) }
    }

    // MARK: - Icon

    enum Icon {
        public static var benefit: Color { Color(UIColor.Icon.benefit) }
        public static var bookmarkActivated: Color { Color(UIColor.Icon.bookmarkActivated) }
        public static var bookmarkDefault: Color { Color(UIColor.Icon.bookmarkDefault) }
        public static var brand: Color { Color(UIColor.Icon.brand) }
        public static var critical: Color { Color(UIColor.Icon.critical) }
        public static var disabled: Color { Color(UIColor.Icon.disabled) }
        public static var focused: Color { Color(UIColor.Icon.focused) }
        public static var focusedAlt: Color { Color(UIColor.Icon.focusedAlt) }
        public static var highlighted: Color { Color(UIColor.Icon.highlighted) }
        public static var highlightedAlt: Color { Color(UIColor.Icon.highlightedAlt) }
        public static var inverse: Color { Color(UIColor.Icon.inverse) }
        public static var inverseAlt: Color { Color(UIColor.Icon.inverseAlt) }
        public static var navigationBar: Color { Color(UIColor.Icon.navigationBar) }
        public static var primary: Color { Color(UIColor.Icon.primary) }
        public static var rating: Color { Color(UIColor.Icon.rating) }
        public static var secondary: Color { Color(UIColor.Icon.secondary) }
        public static var secondaryAlt: Color { Color(UIColor.Icon.secondaryAlt) }
        public static var selectBox: Color { Color(UIColor.Icon.selectBox) }
        public static var tertiary: Color { Color(UIColor.Icon.tertiary) }
    }

    // MARK: - Text

    enum Text {
        public static var benefit: Color { Color(UIColor.Text.benefit) }
        public static var critical: Color { Color(UIColor.Text.critical) }
        public static var criticalAlt: Color { Color(UIColor.Text.criticalAlt) }
        public static var disabled: Color { Color(UIColor.Text.disabled) }
        public static var disabledAlt: Color { Color(UIColor.Text.disabledAlt) }
        public static var focused: Color { Color(UIColor.Text.focused) }
        public static var focusedAlt: Color { Color(UIColor.Text.focusedAlt) }
        public static var highlighted: Color { Color(UIColor.Text.highlighted) }
        public static var highlightedAlt: Color { Color(UIColor.Text.highlightedAlt) }
        public static var inverse: Color { Color(UIColor.Text.inverse) }
        public static var inverseAlt: Color { Color(UIColor.Text.inverseAlt) }
        public static var positive: Color { Color(UIColor.Text.positive) }
        public static var primary: Color { Color(UIColor.Text.primary) }
        public static var primaryAlt: Color { Color(UIColor.Text.primaryAlt) }
        public static var secondary: Color { Color(UIColor.Text.secondary) }
        public static var secondaryAlt: Color { Color(UIColor.Text.secondaryAlt) }
        public static var tertiary: Color { Color(UIColor.Text.tertiary) }
        public static var warning: Color { Color(UIColor.Text.warning) }
    }
}
