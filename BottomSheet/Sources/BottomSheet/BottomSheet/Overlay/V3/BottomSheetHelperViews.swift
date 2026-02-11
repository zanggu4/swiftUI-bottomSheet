//
//  BottomSheetHelperViews.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Helper views used by BottomSheetController.
//

import SwiftUI
import UIKit

// MARK: - BottomSheetDismissable

@available(iOS 15.0, *)
@MainActor
protocol BottomSheetDismissable: AnyObject {
    func dismissSheet()
}

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

// MARK: - SheetHostingController

@available(iOS 15.0, *)
final class SheetHostingController<Content: View>: UIHostingController<Content> {
    var onLayoutChange: (() -> Void)?
    var adjustsSafeAreaTop = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if adjustsSafeAreaTop {
            let systemTop = view.safeAreaInsets.top - additionalSafeAreaInsets.top
            if abs(additionalSafeAreaInsets.top - (-systemTop)) > 0.5 {
                additionalSafeAreaInsets.top = -systemTop
            }
        }
        onLayoutChange?()
    }
}

// MARK: - onChange Compatibility

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            onChange(of: value) { _, newValue in action(newValue) }
        } else {
            onChange(of: value) { newValue in action(newValue) }
        }
    }
}
