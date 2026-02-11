//
//  BottomSheetController.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  A SwiftUI bottom sheet component with UIKit scroll handling.
//

import SwiftUI
import UIKit

// MARK: - BottomSheetController (Internal implementation detail)

@available(iOS 15.0, *)
@MainActor
final class BottomSheetController<Header: View, Content: View>: UIViewController, UIScrollViewDelegate, BottomSheetGestureHandlerDelegate {
    // MARK: - Properties

    private let header: Header
    private let content: Content
    private let maxHeightRatio: CGFloat
    private let avoidsKeyboard: Bool
    private let edgeSwipeBackToDismiss: Bool
    private var onDismiss: (() -> Void)?
    /// (progress, animated)
    var onDragProgressChanged: ((CGFloat, Bool) -> Void)?

    private let sheetView = UIView()
    private let headerContainerView = UIView()
    private let scrollView = UIScrollView()
    private weak var headerHostingController: UIViewController?
    private weak var contentHostingController: UIViewController?

    private var currentSheetHeight: CGFloat = SheetConstants.defaultSheetHeight
    private var currentHeaderHeight: CGFloat = 0
    private var keyboardOffset: CGFloat = 0

    private var needsScroll = false
    private var isDismissing = false
    private var isSheetVisible = false

    private var animator: BottomSheetAnimator?
    private var gestureHandler: BottomSheetGestureHandler?
    private var keyboardBehavior: KeyboardAvoidingBehavior?

    // MARK: - Init

    init(header: Header, content: Content, maxHeightRatio: CGFloat = SheetConstants.maxHeightRatio, avoidsKeyboard: Bool = true, edgeSwipeBackToDismiss: Bool = true, onDismiss: @escaping () -> Void) {
        self.header = header
        self.content = content
        self.maxHeightRatio = maxHeightRatio
        self.avoidsKeyboard = avoidsKeyboard
        self.edgeSwipeBackToDismiss = edgeSwipeBackToDismiss
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // NotificationCenter automatically removes observers on dealloc (iOS 9+).
        // ScrollView pan gesture target is cleaned up when the view hierarchy is released.
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupAnimator()
        setupGestureHandler()

        if avoidsKeyboard {
            setupKeyboardBehavior()
        }
        if edgeSwipeBackToDismiss {
            setupEdgeSwipeGesture()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSheet()

        // Force layout recalculation after SwiftUI hosting controllers settle.
        // On real devices, the initial layout pass may complete before
        // UIHostingController content has finished rendering.
        DispatchQueue.main.async { [weak self] in
            self?.updateSheetHeight()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutFrames()
        updateSheetHeight()
    }

    override func loadView() {
        view = PassThroughView()
    }

    // MARK: - Accessibility

    override func accessibilityPerformEscape() -> Bool {
        dismissSheet()
        return true
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = .clear

        // Sheet view
        sheetView.backgroundColor = .systemBackground
        sheetView.layer.cornerRadius = SheetConstants.cornerRadius
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        view.addSubview(sheetView)

        // Header container
        headerContainerView.backgroundColor = .clear
        sheetView.addSubview(headerContainerView)

        // Header hosting controller
        let headerHosting = UIHostingController(rootView: header)
        headerHosting.view.backgroundColor = .clear
        addChild(headerHosting)
        headerContainerView.addSubview(headerHosting.view)
        headerHosting.didMove(toParent: self)
        headerHostingController = headerHosting

        // Scroll view
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        sheetView.addSubview(scrollView)

        // Content hosting controller (frame-based layout to avoid iOS 15 systemLayoutSizeFitting oscillation)
        let wrappedContent = content.ignoresSafeArea(edges: .bottom)
        let contentHosting = ControlledHostingController(rootView: wrappedContent)
        contentHosting.adjustsSafeAreaTop = true
        contentHosting.view.backgroundColor = .clear
        contentHosting.onLayoutChange = { [weak self] in
            self?.view.setNeedsLayout()
        }
        addChild(contentHosting)
        scrollView.addSubview(contentHosting.view)
        contentHosting.didMove(toParent: self)
        contentHostingController = contentHosting

        // Header drag gesture
        let headerPan = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPanGesture(_:)))
        headerContainerView.addGestureRecognizer(headerPan)

        // Background tap to dismiss
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        view.addGestureRecognizer(backgroundTap)
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
            sheetHeight: currentSheetHeight,
        )
        gestureHandler?.delegate = self

        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollPanGesture(_:)))
    }

    private func setupKeyboardBehavior() {
        keyboardBehavior = KeyboardAvoidingBehavior()
        keyboardBehavior?.onKeyboardChange = { [weak self] height, duration, options in
            self?.keyboardOffset = height
            UIView.animate(withDuration: duration, delay: 0, options: options) {
                self?.layoutFrames()
            }
        }
        keyboardBehavior?.startObserving(in: view)
    }

    private func setupEdgeSwipeGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipeGesture(_:)))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }

    // MARK: - Frame Layout

    private func layoutFrames() {
        let width = view.bounds.width
        let viewHeight = view.bounds.height

        // Sheet
        let sheetY = isSheetVisible
            ? viewHeight - currentSheetHeight - keyboardOffset
            : viewHeight
        sheetView.frame = CGRect(x: 0, y: sheetY, width: width, height: currentSheetHeight)

        // Header
        headerContainerView.frame = CGRect(x: 0, y: 0, width: width, height: currentHeaderHeight)
        headerHostingController?.view.frame = headerContainerView.bounds

        // ScrollView
        let scrollY = currentHeaderHeight
        let scrollHeight = currentSheetHeight - currentHeaderHeight
        scrollView.frame = CGRect(x: 0, y: scrollY, width: width, height: max(0, scrollHeight))

        // Content origin correction (UIHostingController internal layout defense)
        if let contentView = contentHostingController?.view,
           contentView.frame.origin != .zero {
            contentView.frame.origin = .zero
        }
    }

    // MARK: - Show / Dismiss Orchestration

    private func showSheet() {
        layoutFrames()  // off-screen (isSheetVisible = false)
        isSheetVisible = true
        reportDragProgress(0, animated: false)
        animator?.animateSpringLayout(layout: { [weak self] in
            self?.layoutFrames()  // on-screen
        }) {
            // show complete
        }
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
            self?.layoutFrames()  // off-screen
        }) { [weak self] in
            self?.onDismiss?()
            self?.onDismiss = nil
        }
    }

    private func reportDragProgress(_ progress: CGFloat, animated: Bool) {
        onDragProgressChanged?(progress, animated)
    }

    // MARK: - Height Calculation

    private func updateSheetHeight() {
        guard let contentHosting = contentHostingController else { return }
        guard !scrollView.isDragging, !scrollView.isDecelerating, !scrollView.isTracking else { return }

        let width = view.bounds.width
        guard width > 0 else { return }

        // Header
        if let headerHosting = headerHostingController {
            let headerSize = headerHosting.view.sizeThatFits(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
            currentHeaderHeight = headerSize.height
        }

        // Content
        let contentHeight = contentHosting.view.sizeThatFits(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        ).height
        contentHosting.view.frame = CGRect(x: 0, y: 0, width: width, height: contentHeight)
        scrollView.contentSize = CGSize(width: width, height: contentHeight)

        let safeAreaBottom = view.safeAreaInsets.bottom
        let maxHeight = view.bounds.height * maxHeightRatio
        let calculatedHeight = currentHeaderHeight + contentHeight + safeAreaBottom
        let finalHeight = min(calculatedHeight, maxHeight)

        let heightChanged = currentSheetHeight != finalHeight
        if heightChanged {
            currentSheetHeight = finalHeight
            gestureHandler?.updateSheetHeight(finalHeight)
        }

        let previousNeedsScroll = needsScroll
        needsScroll = calculatedHeight > maxHeight

        let shouldAnimate = heightChanged && isSheetVisible && gestureHandler?.isSheetBeingDragged != true
        if shouldAnimate {
            UIView.animate(
                withDuration: SheetConstants.snapBackAnimationDuration,
                delay: 0,
                usingSpringWithDamping: SheetConstants.springDamping,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction]
            ) {
                self.layoutFrames()
            }
        } else {
            layoutFrames()
        }

        if previousNeedsScroll, !needsScroll, scrollView.contentOffset.y > 0 {
            UIView.animate(withDuration: 0.2) {
                self.scrollView.contentOffset.y = 0
            }
        }
    }

    // MARK: - Gesture Actions

    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        guard !sheetView.frame.contains(location) else { return }
        dismissSheet()
    }

    @objc private func handleEdgeSwipeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        gestureHandler?.handleEdgeSwipe(gesture)
    }

    @objc private func handleHeaderPanGesture(_ gesture: UIPanGestureRecognizer) {
        gestureHandler?.handleHeaderPan(gesture)
    }

    @objc private func handleScrollPanGesture(_ gesture: UIPanGestureRecognizer) {
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
