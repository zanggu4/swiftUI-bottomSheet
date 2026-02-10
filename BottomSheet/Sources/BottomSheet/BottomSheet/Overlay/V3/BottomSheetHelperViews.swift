//
//  BottomSheetHelperViews.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Helper views used by BottomSheetController.
//

import SwiftUI
import UIKit

// MARK: - PassThroughView

/// A view that passes through touches outside its designated sheet area.
@available(iOS 15.0, *)
final class PassThroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        // Return self for background taps so gesture recognizers can fire
        if hitView == self {
            return self
        }
        return hitView
    }
}

// MARK: - ControlledHostingController

@available(iOS 15.0, *)
final class ControlledHostingController<Content: View>: UIHostingController<Content> {
    var onLayoutChange: (() -> Void)?
    var adjustsSafeAreaTop = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onLayoutChange?()
        guard adjustsSafeAreaTop else { return }
        // view.safeAreaInsets.top includes additionalSafeAreaInsets.top,
        // so compute the system safe area by subtracting it out.
        let systemTop = view.safeAreaInsets.top - additionalSafeAreaInsets.top
        if abs(additionalSafeAreaInsets.top - (-systemTop)) > 0.5 {
            additionalSafeAreaInsets.top = -systemTop
        }
    }
}

