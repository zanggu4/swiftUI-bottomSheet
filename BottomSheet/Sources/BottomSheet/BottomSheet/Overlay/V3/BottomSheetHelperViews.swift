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
    weak var sheetView: UIView?

    init(sheetView: UIView) {
        self.sheetView = sheetView
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    private var didAdjustSafeArea = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onLayoutChange?()
        guard adjustsSafeAreaTop, !didAdjustSafeArea else { return }
        didAdjustSafeArea = true
        additionalSafeAreaInsets.top = -view.safeAreaInsets.top
    }
}

