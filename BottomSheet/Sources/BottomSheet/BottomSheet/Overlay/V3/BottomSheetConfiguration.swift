//
//  BottomSheetConfiguration.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Internal constants for BottomSheet.
//

import UIKit

// MARK: - SheetConstants

enum SheetConstants {
    static let cornerRadius: CGFloat = 16
    static let maxHeightRatio: CGFloat = 0.9
    static let dimOpacity: CGFloat = 0.4
    static let showAnimationDuration: TimeInterval = 0.35
    static let hideAnimationDuration: TimeInterval = 0.25
    static let snapBackAnimationDuration: TimeInterval = 0.3
    static let springDamping: CGFloat = 0.85
    static let dismissThreshold: CGFloat = 200
    static let velocityThreshold: CGFloat = 500
    static let defaultSheetHeight: CGFloat = 300
    static let horizontalDragResistance: CGFloat = 0.4
    static let edgeSwipeDismissThreshold: CGFloat = 50
}
