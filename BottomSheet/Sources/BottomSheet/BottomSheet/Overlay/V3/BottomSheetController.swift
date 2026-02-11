//
//  BottomSheetController.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Frame-based BottomSheet controller for iOS 15+.
//

import SwiftUI
import UIKit

// MARK: - BottomSheetController (frame-based, iOS 15+)

@available(iOS 15.0, *)
@MainActor
final class BottomSheetController<Header: View, Content: View>: BottomSheetBaseController<Header, Content> {

    // MARK: - Lifecycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutFrames()
        updateSheetHeight()
    }

    // MARK: - Template Method Overrides

    override func setupSheetLayout() {
        // Header
        if hasHeader {
            headerContainerView.backgroundColor = .clear
            sheetView.addSubview(headerContainerView)

            let headerHosting = UIHostingController(rootView: header)
            headerHosting.view.backgroundColor = .clear
            addChild(headerHosting)
            headerContainerView.addSubview(headerHosting.view)
            headerHosting.didMove(toParent: self)
            headerHostingController = headerHosting

            let headerPan = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPanGesture(_:)))
            headerContainerView.addGestureRecognizer(headerPan)
        }

        // ScrollView
        sheetView.addSubview(scrollView)

        // Content
        let wrappedContent = content.ignoresSafeArea(edges: .bottom)
        let contentHosting = SheetHostingController(rootView: wrappedContent)
        contentHosting.adjustsSafeAreaTop = true
        contentHosting.view.backgroundColor = .clear
        addChild(contentHosting)
        scrollView.addSubview(contentHosting.view)
        contentHosting.view.autoresizingMask = []
        contentHosting.didMove(toParent: self)
        contentHostingController = contentHosting
    }

    override func performLayout() {
        layoutFrames()
    }

    override func calculateContentHeight() -> CGFloat {
        guard let contentHosting = contentHostingController else { return 0 }

        let width = view.bounds.width
        guard width > 0 else { return 0 }

        // Header measurement
        if hasHeader, let headerHosting = headerHostingController {
            let headerSize = headerHosting.view.sizeThatFits(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
            )
            currentHeaderHeight = headerSize.height
        }

        // Content measurement
        let contentHeight = contentHosting.view.sizeThatFits(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        ).height
        contentHosting.view.frame = CGRect(x: 0, y: 0, width: width, height: contentHeight)
        scrollView.contentSize = CGSize(width: width, height: contentHeight)

        return contentHeight
    }

    override func applyKeyboardOffset(_ height: CGFloat, duration: TimeInterval, options: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.layoutFrames()
        }
    }

    // MARK: - Frame Layout

    private func layoutFrames() {
        let width = view.bounds.width
        let viewHeight = view.bounds.height

        // Sheet — bounds+center (safe when transform != .identity during drag)
        let sheetY = isSheetVisible
            ? viewHeight - currentSheetHeight - keyboardOffset
            : viewHeight
        let newBounds = CGRect(x: 0, y: 0, width: width, height: currentSheetHeight)
        let newCenter = CGPoint(x: width / 2, y: sheetY + currentSheetHeight / 2)
        if sheetView.bounds != newBounds { sheetView.bounds = newBounds }
        if sheetView.center != newCenter { sheetView.center = newCenter }

        // Header
        if hasHeader {
            let headerFrame = CGRect(x: 0, y: 0, width: width, height: currentHeaderHeight)
            if headerContainerView.frame != headerFrame {
                headerContainerView.frame = headerFrame
                headerHostingController?.view.frame = headerContainerView.bounds
            }
        }

        // ScrollView — skip if unchanged → breaks layout cycle, preserves bounce
        let scrollY = currentHeaderHeight
        let scrollHeight = currentSheetHeight - currentHeaderHeight
        let scrollFrame = CGRect(x: 0, y: scrollY, width: width, height: max(0, scrollHeight))
        if scrollView.frame != scrollFrame {
            scrollView.frame = scrollFrame
        }

        // Content origin correction (UIHostingController internal layout defense)
        if let contentView = contentHostingController?.view,
           contentView.frame.origin != .zero {
            contentView.frame.origin = .zero
        }
    }
}
