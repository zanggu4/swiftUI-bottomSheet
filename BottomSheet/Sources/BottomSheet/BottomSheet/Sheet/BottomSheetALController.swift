//
//  BottomSheetALController.swift
//  BottomSheet
//
//  Auto Layout based BottomSheet controller for iOS 16+.
//  Uses UIHostingController.sizingOptions(.intrinsicContentSize)
//  to avoid manual frame calculation issues with iOS 16+ hosting layout.
//

import SwiftUI
import UIKit

// MARK: - BottomSheetALController (Auto Layout, iOS 16+)

@available(iOS 16.0, *)
@MainActor
final class BottomSheetALController<Header: View, Content: View>: BottomSheetBaseController<Header, Content> {

    // MARK: - Constraints

    private var sheetHeightConstraint: NSLayoutConstraint?
    private var sheetBottomConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSheetHeight()
    }

    // MARK: - Template Method Overrides

    override func setupSheetLayout() {
        sheetView.translatesAutoresizingMaskIntoConstraints = false

        // Header
        if hasHeader {
            headerContainerView.backgroundColor = .clear
            headerContainerView.translatesAutoresizingMaskIntoConstraints = false
            sheetView.addSubview(headerContainerView)

            let headerHosting = SheetHostingController(rootView: header)
            headerHosting.sizingOptions = .intrinsicContentSize
            headerHosting.view.backgroundColor = .clear
            headerHosting.view.translatesAutoresizingMaskIntoConstraints = false
            headerHosting.onLayoutChange = { [weak self] in
                self?.view.setNeedsLayout()
            }
            addChild(headerHosting)
            headerContainerView.addSubview(headerHosting.view)
            headerHosting.didMove(toParent: self)
            headerHostingController = headerHosting

            let headerPan = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPanGesture(_:)))
            headerContainerView.addGestureRecognizer(headerPan)
        }

        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(scrollView)

        // Content
        let wrappedContent = content.ignoresSafeArea(edges: .bottom)
        let contentHosting = SheetHostingController(rootView: wrappedContent)
        contentHosting.sizingOptions = .intrinsicContentSize
        contentHosting.adjustsSafeAreaTop = true
        contentHosting.view.backgroundColor = .clear
        contentHosting.view.translatesAutoresizingMaskIntoConstraints = false
        contentHosting.onLayoutChange = { [weak self] in
            self?.view.setNeedsLayout()
        }
        addChild(contentHosting)
        scrollView.addSubview(contentHosting.view)
        contentHosting.didMove(toParent: self)
        contentHostingController = contentHosting

        // Constraints
        setupConstraints()
    }

    override func performLayout() {
        view.layoutIfNeeded()
    }

    override func calculateContentHeight() -> CGFloat {
        currentHeaderHeight = hasHeader ? headerContainerView.bounds.height : 0

        guard let contentView = contentHostingController?.view else { return 0 }
        let height = contentView.intrinsicContentSize.height
        return height == UIView.noIntrinsicMetric ? 0 : height
    }

    override func applyHeightChange(_ height: CGFloat) {
        sheetHeightConstraint?.constant = height
    }

    override func applyKeyboardOffset(_ height: CGFloat, duration: TimeInterval, options: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.sheetBottomConstraint?.constant = self.isSheetVisible ? -height : self.currentSheetHeight
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Show / Dismiss (constraint-based overrides)

    override func showSheet() {
        view.layoutIfNeeded()
        isSheetVisible = true
        reportDragProgress(0, animated: false)

        sheetBottomConstraint?.constant = -keyboardOffset
        animator?.animateSpringLayout(layout: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { }
    }

    override func dismissSheet() {
        guard !isDismissing else { return }
        isDismissing = true
        isSheetVisible = false
        reportDragProgress(1, animated: true)

        guard animator != nil else {
            onDismiss?()
            onDismiss = nil
            return
        }

        sheetBottomConstraint?.constant = currentSheetHeight
        animator?.animateEaseOutLayout(layout: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { [weak self] in
            self?.onDismiss?()
            self?.onDismiss = nil
        }
    }

    // MARK: - Constraints

    private func setupConstraints() {
        guard let contentView = contentHostingController?.view else { return }

        // Sheet view
        let bottomConstraint = sheetView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: SheetConstants.defaultSheetHeight
        )
        sheetBottomConstraint = bottomConstraint

        let heightConstraint = sheetView.heightAnchor.constraint(
            equalToConstant: SheetConstants.defaultSheetHeight
        )
        sheetHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            heightConstraint,
        ])

        if hasHeader, let headerView = headerHostingController?.view {
            // Header container
            NSLayoutConstraint.activate([
                headerContainerView.topAnchor.constraint(equalTo: sheetView.topAnchor),
                headerContainerView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
                headerContainerView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            ])

            // Header hosting view (pinned to container, intrinsic height drives container)
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
                headerView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
                headerView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            ])

            // Scroll view (below header)
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor),
            ])
        } else {
            // Scroll view (directly at top of sheet)
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: sheetView.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor),
            ])
        }

        // Content hosting view → scroll view content layout guide
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }
}
