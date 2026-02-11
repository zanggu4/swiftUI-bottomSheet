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

// MARK: - ALHostingController (private helper)

@available(iOS 16.0, *)
private final class ALHostingController<Content: View>: UIHostingController<Content> {
    var onIntrinsicSizeChange: (() -> Void)?
    var adjustsSafeAreaTop = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if adjustsSafeAreaTop {
            let systemTop = view.safeAreaInsets.top - additionalSafeAreaInsets.top
            if abs(additionalSafeAreaInsets.top - (-systemTop)) > 0.5 {
                additionalSafeAreaInsets.top = -systemTop
            }
        }

        onIntrinsicSizeChange?()
    }
}

// MARK: - BottomSheetALController

@available(iOS 16.0, *)
@MainActor
final class BottomSheetALController<Header: View, Content: View>: UIViewController,
    UIScrollViewDelegate, BottomSheetGestureHandlerDelegate, BottomSheetDismissable
{
    // MARK: - Properties

    private let header: Header
    private let content: Content
    private let maxHeightRatio: CGFloat
    private let avoidsKeyboard: Bool
    private let edgeSwipeBackToDismiss: Bool
    private var onDismiss: (() -> Void)?
    var onDragProgressChanged: ((CGFloat, Bool) -> Void)?

    private let sheetView = UIView()
    private let headerContainerView = UIView()
    private let scrollView = UIScrollView()
    private weak var contentHostingController: UIViewController?

    // Auto Layout constraints
    private var sheetHeightConstraint: NSLayoutConstraint!
    private var sheetBottomConstraint: NSLayoutConstraint!

    private var currentSheetHeight: CGFloat = SheetConstants.defaultSheetHeight
    private var keyboardOffset: CGFloat = 0

    private let hasHeader: Bool

    private var needsScroll = false
    private var isDismissing = false
    private var isSheetVisible = false

    private var animator: BottomSheetAnimator?
    private var gestureHandler: BottomSheetGestureHandler?
    private var keyboardBehavior: KeyboardAvoidingBehavior?

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
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

        DispatchQueue.main.async { [weak self] in
            self?.updateSheetHeight()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)

        // Header container (only when header is provided)
        if hasHeader {
            headerContainerView.backgroundColor = .clear
            headerContainerView.translatesAutoresizingMaskIntoConstraints = false
            sheetView.addSubview(headerContainerView)

            // Header hosting controller
            let headerHosting = ALHostingController(rootView: header)
            headerHosting.sizingOptions = .intrinsicContentSize
            headerHosting.view.backgroundColor = .clear
            headerHosting.view.translatesAutoresizingMaskIntoConstraints = false
            headerHosting.onIntrinsicSizeChange = { [weak self] in
                self?.view.setNeedsLayout()
            }
            addChild(headerHosting)
            headerContainerView.addSubview(headerHosting.view)
            headerHosting.didMove(toParent: self)
        }

        // Scroll view
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(scrollView)

        // Content hosting controller
        let wrappedContent = content.ignoresSafeArea(edges: .bottom)
        let contentHosting = ALHostingController(rootView: wrappedContent)
        contentHosting.sizingOptions = .intrinsicContentSize
        contentHosting.adjustsSafeAreaTop = true
        contentHosting.view.backgroundColor = .clear
        contentHosting.view.translatesAutoresizingMaskIntoConstraints = false
        contentHosting.onIntrinsicSizeChange = { [weak self] in
            self?.view.setNeedsLayout()
        }
        addChild(contentHosting)
        scrollView.addSubview(contentHosting.view)
        contentHosting.didMove(toParent: self)
        contentHostingController = contentHosting

        // Header drag gesture (only when header is provided)
        if hasHeader {
            let headerPan = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPanGesture(_:)))
            headerContainerView.addGestureRecognizer(headerPan)
        }

        // Background tap to dismiss
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        view.addGestureRecognizer(backgroundTap)
    }

    private func setupConstraints() {
        guard let contentView = contentHostingController?.view else { return }

        // Sheet view
        sheetBottomConstraint = sheetView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: SheetConstants.defaultSheetHeight
        )
        sheetHeightConstraint = sheetView.heightAnchor.constraint(
            equalToConstant: SheetConstants.defaultSheetHeight
        )

        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetBottomConstraint,
            sheetHeightConstraint,
        ])

        if hasHeader {
            guard let headerHosting = children.first else { return }
            let headerView = headerHosting.view!

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
            guard let self else { return }
            self.keyboardOffset = height
            UIView.animate(withDuration: duration, delay: 0, options: options) {
                self.sheetBottomConstraint.constant = self.isSheetVisible ? -height : self.currentSheetHeight
                self.view.layoutIfNeeded()
            }
        }
        keyboardBehavior?.startObserving(in: view)
    }

    private func setupEdgeSwipeGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipeGesture(_:)))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }

    // MARK: - Show / Dismiss

    private func showSheet() {
        view.layoutIfNeeded()
        isSheetVisible = true
        reportDragProgress(0, animated: false)

        sheetBottomConstraint.constant = -keyboardOffset
        animator?.animateSpringLayout(layout: { [weak self] in
            self?.view.layoutIfNeeded()
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

        sheetBottomConstraint.constant = currentSheetHeight
        animator?.animateEaseOutLayout(layout: { [weak self] in
            self?.view.layoutIfNeeded()
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
        guard gestureHandler?.isSheetBeingDragged != true else { return }

        guard let contentView = contentHostingController?.view else { return }
        let viewHeight = view.bounds.height
        guard viewHeight > 0 else { return }

        let headerHeight = hasHeader ? headerContainerView.bounds.height : 0
        let contentHeight = contentView.intrinsicContentSize.height
        guard contentHeight != UIView.noIntrinsicMetric else { return }

        let safeAreaBottom = view.safeAreaInsets.bottom
        let maxHeight = viewHeight * maxHeightRatio
        let calculatedHeight = headerHeight + contentHeight + safeAreaBottom
        let finalHeight = min(calculatedHeight, maxHeight)

        let heightChanged = currentSheetHeight != finalHeight
        if heightChanged {
            currentSheetHeight = finalHeight
            gestureHandler?.updateSheetHeight(finalHeight)
            sheetHeightConstraint.constant = finalHeight
        }

        let previousNeedsScroll = needsScroll
        needsScroll = calculatedHeight > maxHeight

        let shouldAnimate = heightChanged && isSheetVisible
        if shouldAnimate {
            UIView.animate(
                withDuration: SheetConstants.snapBackAnimationDuration,
                delay: 0,
                usingSpringWithDamping: SheetConstants.springDamping,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction]
            ) {
                self.view.layoutIfNeeded()
            }
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
