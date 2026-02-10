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

    private var sheetHeightConstraint: NSLayoutConstraint?
    private var sheetBottomConstraint: NSLayoutConstraint?
    private var headerHeightConstraint: NSLayoutConstraint?

    private var needsScroll = false
    private var isDismissing = false

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
        keyboardBehavior?.stopObserving()
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
        animator?.showAnimation()

        // Force layout recalculation after SwiftUI hosting controllers settle.
        // On real devices, the initial layout pass may complete before
        // UIHostingController content has finished rendering.
        DispatchQueue.main.async { [weak self] in
            self?.updateSheetHeight()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSheetHeight()
    }

    override func loadView() {
        view = PassThroughView(sheetView: sheetView)
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

        // Header container
        headerContainerView.backgroundColor = .clear
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(headerContainerView)

        // Header hosting controller
        let headerHosting = UIHostingController(rootView: header)
        headerHosting.view.backgroundColor = .clear
        headerHosting.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(headerHosting)
        headerContainerView.addSubview(headerHosting.view)
        headerHosting.didMove(toParent: self)
        headerHostingController = headerHosting

        // Scroll view
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(scrollView)

        // Content hosting controller (frame-based layout to avoid iOS 15 systemLayoutSizeFitting oscillation)
        let wrappedContent = content.ignoresSafeArea(edges: .bottom)
        let contentHosting = ControlledHostingController(rootView: wrappedContent)
        contentHosting.adjustsSafeAreaTop = true
        contentHosting.view.backgroundColor = .clear
        addChild(contentHosting)
        scrollView.addSubview(contentHosting.view)
        contentHosting.didMove(toParent: self)
        contentHostingController = contentHosting

        // Header height constraint (will be updated)
        headerHeightConstraint = headerContainerView.heightAnchor.constraint(equalToConstant: 0)
        headerHeightConstraint?.isActive = true

        // Constraints
        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            headerContainerView.topAnchor.constraint(equalTo: sheetView.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),

            headerHosting.view.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            headerHosting.view.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            headerHosting.view.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            headerHosting.view.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor),
        ])

        // Sheet height constraint (will be updated)
        sheetHeightConstraint = sheetView.heightAnchor.constraint(equalToConstant: SheetConstants.defaultSheetHeight)
        sheetHeightConstraint?.isActive = true

        // Sheet bottom constraint (starts off-screen)
        sheetBottomConstraint = sheetView.topAnchor.constraint(equalTo: view.bottomAnchor)
        sheetBottomConstraint?.isActive = true

        // Header drag gesture
        let headerPan = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPanGesture(_:)))
        headerContainerView.addGestureRecognizer(headerPan)

        // Background tap to dismiss
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        view.addGestureRecognizer(backgroundTap)
    }

    private func setupAnimator() {
        animator = BottomSheetAnimator(sheetView: sheetView, containerView: view)
        animator?.setBottomConstraint(sheetBottomConstraint)
        animator?.onDragProgressChanged = { [weak self] progress, animated in
            self?.onDragProgressChanged?(progress, animated)
        }
        animator?.onBottomConstraintChanged = { [weak self] newConstraint in
            self?.sheetBottomConstraint = newConstraint
            self?.keyboardBehavior?.updateConstraint(newConstraint)
        }
    }

    private func setupGestureHandler() {
        gestureHandler = BottomSheetGestureHandler(
            containerView: view,
            sheetView: sheetView,
            scrollView: scrollView,
            edgeSwipeBackToDismiss: edgeSwipeBackToDismiss,
            sheetHeight: sheetHeightConstraint?.constant ?? SheetConstants.defaultSheetHeight,
        )
        gestureHandler?.delegate = self

        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollPanGesture(_:)))
    }

    private func setupKeyboardBehavior() {
        guard let constraint = sheetBottomConstraint else { return }
        keyboardBehavior = KeyboardAvoidingBehavior()
        keyboardBehavior?.startObserving(bottomConstraint: constraint, view: view)
    }

    private func setupEdgeSwipeGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipeGesture(_:)))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }

    // MARK: - Height Calculation

    private func updateSheetHeight() {
        guard let contentHosting = contentHostingController else { return }
        guard !scrollView.isDragging, !scrollView.isDecelerating else { return }

        let width = view.bounds.width
        let targetSize = CGSize(
            width: width,
            height: UIView.layoutFittingCompressedSize.height,
        )

        var headerHeight: CGFloat = 0
        if let headerHosting = headerHostingController {
            let headerSize = headerHosting.view.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel,
            )
            headerHeight = headerSize.height
        }

        // Frame-based sizing for content (avoids iOS 15 systemLayoutSizeFitting oscillation in UIScrollView)
        let contentHeight = contentHosting.view.sizeThatFits(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        ).height
        contentHosting.view.frame = CGRect(x: 0, y: 0, width: width, height: contentHeight)
        scrollView.contentSize = CGSize(width: width, height: contentHeight)

        let safeAreaBottom = view.safeAreaInsets.bottom
        let maxHeight = view.bounds.height * maxHeightRatio
        let calculatedHeight = headerHeight + contentHeight + safeAreaBottom
        let finalHeight = min(calculatedHeight, maxHeight)

        if headerHeightConstraint?.constant != headerHeight {
            headerHeightConstraint?.constant = headerHeight
        }
        if sheetHeightConstraint?.constant != finalHeight {
            sheetHeightConstraint?.constant = finalHeight
            gestureHandler?.updateSheetHeight(finalHeight)
        }

        let previousNeedsScroll = needsScroll
        needsScroll = calculatedHeight > maxHeight

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

    // MARK: - Dismiss

    func dismissSheet() {
        guard !isDismissing else { return }
        isDismissing = true

        animator?.hideAnimation { [weak self] in
            self?.onDismiss?()
            self?.onDismiss = nil
        }
    }

    // MARK: - BottomSheetGestureHandlerDelegate

    func gestureHandlerRequestsDismiss() {
        dismissSheet()
    }

    func gestureHandlerRequestsSlideOutRight() {
        guard !isDismissing else { return }
        isDismissing = true

        animator?.slideOutRightAnimation { [weak self] in
            self?.onDismiss?()
            self?.onDismiss = nil
        }
    }

    func gestureHandlerRequestsSnapBack() {
        animator?.snapBackAnimation()
    }

    func gestureHandlerDidUpdateProgress(_ progress: CGFloat, animated: Bool) {
        onDragProgressChanged?(progress, animated)
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
