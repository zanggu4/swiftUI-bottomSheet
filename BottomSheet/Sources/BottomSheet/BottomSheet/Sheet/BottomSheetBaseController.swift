//
//  BottomSheetBaseController.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Common base class for frame-based and Auto Layout bottom sheet controllers.
//

import SwiftUI
import UIKit

// MARK: - BottomSheetBaseController

@available(iOS 15.0, *)
@MainActor
class BottomSheetBaseController<Header: View, Content: View>: UIViewController,
    UIScrollViewDelegate, BottomSheetGestureHandlerDelegate, BottomSheetDismissable
{
    // MARK: - Properties

    let header: Header
    let content: Content
    let maxHeightRatio: CGFloat
    let avoidsKeyboard: Bool
    let edgeSwipeBackToDismiss: Bool
    var onDismiss: (() -> Void)?
    var onDragProgressChanged: ((CGFloat, Bool) -> Void)?

    let hasHeader: Bool
    let sheetView = UIView()
    let headerContainerView = UIView()
    let scrollView = UIScrollView()
    weak var headerHostingController: UIViewController?
    weak var contentHostingController: UIViewController?

    var currentSheetHeight: CGFloat = SheetConstants.defaultSheetHeight
    var currentHeaderHeight: CGFloat = 0
    var keyboardOffset: CGFloat = 0
    var needsScroll = false
    var isDismissing = false
    var isSheetVisible = false

    var animator: BottomSheetAnimator?
    var gestureHandler: BottomSheetGestureHandler?
    var keyboardBehavior: KeyboardAvoidingBehavior?

    // MARK: - Init

    init(
        header: Header,
        content: Content,
        maxHeightRatio: CGFloat = SheetConstants.maxHeightRatio,
        avoidsKeyboard: Bool = true,
        edgeSwipeBackToDismiss: Bool = true,
        onDismiss: @escaping () -> Void
    ) {
        self.header = header
        self.content = content
        self.maxHeightRatio = maxHeightRatio
        self.avoidsKeyboard = avoidsKeyboard
        self.edgeSwipeBackToDismiss = edgeSwipeBackToDismiss
        self.onDismiss = onDismiss
        self.hasHeader = !(Header.self == EmptyView.self)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = PassThroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheetView()
        setupScrollView()
        setupSheetLayout()
        setupAnimator()
        setupGestureHandler()
        setupBackgroundTap()
        if avoidsKeyboard { setupKeyboardBehavior() }
        if edgeSwipeBackToDismiss { setupEdgeSwipeGesture() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSheet()
        // Force layout recalculation after SwiftUI hosting controllers settle.
        DispatchQueue.main.async { [weak self] in
            self?.updateSheetHeight()
        }
    }

    // MARK: - Accessibility

    override func accessibilityPerformEscape() -> Bool {
        dismissSheet()
        return true
    }

    // MARK: - Template Methods (subclass override points)

    func setupSheetLayout() { }
    func performLayout() { }
    func calculateContentHeight() -> CGFloat { 0 }
    func applyHeightChange(_ height: CGFloat) { }
    func applyKeyboardOffset(_ height: CGFloat, duration: TimeInterval, options: UIView.AnimationOptions) { }

    // MARK: - Common Setup

    private func setupSheetView() {
        view.backgroundColor = .clear
        sheetView.backgroundColor = .systemBackground
        sheetView.layer.cornerRadius = SheetConstants.cornerRadius
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        view.addSubview(sheetView)
    }

    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
    }

    private func setupAnimator() {
        animator = BottomSheetAnimator(sheetView: sheetView, containerView: view)
    }

    private func setupGestureHandler() {
        gestureHandler = BottomSheetGestureHandler(
            containerView: view,
            sheetView: sheetView,
            scrollView: scrollView,
            edgeSwipeBackToDismiss: edgeSwipeBackToDismiss,
            sheetHeight: currentSheetHeight
        )
        gestureHandler?.delegate = self
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollPanGesture(_:)))
    }

    private func setupBackgroundTap() {
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        view.addGestureRecognizer(backgroundTap)
    }

    private func setupEdgeSwipeGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipeGesture(_:)))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }

    private func setupKeyboardBehavior() {
        keyboardBehavior = KeyboardAvoidingBehavior()
        keyboardBehavior?.onKeyboardChange = { [weak self] height, duration, options in
            self?.keyboardOffset = height
            self?.applyKeyboardOffset(height, duration: duration, options: options)
        }
        keyboardBehavior?.startObserving(in: view)
    }

    // MARK: - Show / Dismiss

    func showSheet() {
        performLayout()
        isSheetVisible = true
        reportDragProgress(0, animated: false)
        animator?.animateSpringLayout(layout: { [weak self] in
            self?.performLayout()
        }) { }
    }

    func dismissSheet() {
        guard !isDismissing else { return }
        isDismissing = true
        isSheetVisible = false
        reportDragProgress(1, animated: true)

        guard animator != nil else {
            onDismiss?()
            onDismiss = nil
            return
        }

        animator?.animateEaseOutLayout(layout: { [weak self] in
            self?.performLayout()
        }) { [weak self] in
            self?.onDismiss?()
            self?.onDismiss = nil
        }
    }

    func reportDragProgress(_ progress: CGFloat, animated: Bool) {
        onDragProgressChanged?(progress, animated)
    }

    // MARK: - Height Calculation

    func updateSheetHeight() {
        guard gestureHandler?.isSheetBeingDragged != true else { return }

        let viewHeight = view.bounds.height
        guard viewHeight > 0 else { return }

        let contentHeight = calculateContentHeight()
        guard contentHeight > 0 else { return }

        let headerHeight = currentHeaderHeight
        let safeAreaBottom = view.safeAreaInsets.bottom
        let maxHeight = viewHeight * maxHeightRatio
        let calculatedHeight = headerHeight + contentHeight + safeAreaBottom
        let finalHeight = min(calculatedHeight, maxHeight)

        let heightChanged = currentSheetHeight != finalHeight
        if heightChanged {
            currentSheetHeight = finalHeight
            gestureHandler?.updateSheetHeight(finalHeight)
            applyHeightChange(finalHeight)
        }

        let previousNeedsScroll = needsScroll
        needsScroll = calculatedHeight > maxHeight

        if heightChanged, isSheetVisible {
            UIView.animate(
                withDuration: SheetConstants.snapBackAnimationDuration,
                delay: 0,
                usingSpringWithDamping: SheetConstants.springDamping,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction]
            ) {
                self.performLayout()
            }
        }

        if previousNeedsScroll, !needsScroll, scrollView.contentOffset.y > 0 {
            UIView.animate(withDuration: 0.2) {
                self.scrollView.contentOffset.y = 0
            }
        }
    }

    // MARK: - Gesture Actions

    @objc func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        guard !sheetView.frame.contains(location) else { return }
        dismissSheet()
    }

    @objc func handleEdgeSwipeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        gestureHandler?.handleEdgeSwipe(gesture)
    }

    @objc func handleHeaderPanGesture(_ gesture: UIPanGestureRecognizer) {
        gestureHandler?.handleHeaderPan(gesture)
    }

    @objc func handleScrollPanGesture(_ gesture: UIPanGestureRecognizer) {
        gestureHandler?.handlePan(gesture)
    }

    // MARK: - BottomSheetGestureHandlerDelegate

    func gestureHandlerRequestsDismiss() {
        dismissSheet()
    }

    func gestureHandlerRequestsSlideOutRight() {
        guard !isDismissing else { return }
        isDismissing = true

        reportDragProgress(1, animated: true)

        guard animator != nil else {
            onDismiss?()
            onDismiss = nil
            return
        }

        animator?.animateSlideOutRight { [weak self] in
            self?.onDismiss?()
            self?.onDismiss = nil
        }
    }

    func gestureHandlerRequestsSnapBack() {
        animator?.animateSnapBack()
    }

    func gestureHandlerDidUpdateProgress(_ progress: CGFloat, animated: Bool) {
        reportDragProgress(progress, animated: animated)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if gestureHandler?.isSheetBeingDragged == true {
            scrollView.contentOffset.y = 0
            return
        }

        if !needsScroll, scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }
}
