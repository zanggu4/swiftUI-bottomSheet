//
//  BottomSheetPresenter.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Present-style bottom sheet using UIViewController presentation.
//

import SwiftUI
import UIKit

// MARK: - View Modifier (Present Style)

@available(iOS 15.0, *)
public extension View {
    /// Presents a bottom sheet using UIViewController presentation.
    func presentBottomSheet(
        isPresented: Binding<Bool>,
        maxHeightRatio: CGFloat = 0.9,
        avoidsKeyboard: Bool = true,
        edgeSwipeBackToDismiss: Bool = true,
        @ViewBuilder content: @escaping () -> some View,
    ) -> some View {
        presentBottomSheet(isPresented: isPresented, maxHeightRatio: maxHeightRatio, avoidsKeyboard: avoidsKeyboard, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss, header: { EmptyView() }, content: content)
    }

    /// Presents a bottom sheet with a custom header using UIViewController presentation.
    func presentBottomSheet(
        isPresented: Binding<Bool>,
        maxHeightRatio: CGFloat = 0.9,
        avoidsKeyboard: Bool = true,
        edgeSwipeBackToDismiss: Bool = true,
        @ViewBuilder header: @escaping () -> some View,
        @ViewBuilder content: @escaping () -> some View,
    ) -> some View {
        modifier(BottomSheetPresentModifier(isPresented: isPresented, maxHeightRatio: maxHeightRatio, avoidsKeyboard: avoidsKeyboard, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss, header: header, content: content))
    }

    /// Presents a bottom sheet using UIViewController presentation when item is non-nil.
    func presentBottomSheet<Item>(
        item: Binding<Item?>,
        maxHeightRatio: CGFloat = 0.9,
        avoidsKeyboard: Bool = true,
        edgeSwipeBackToDismiss: Bool = true,
        @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View {
        presentBottomSheet(item: item, maxHeightRatio: maxHeightRatio, avoidsKeyboard: avoidsKeyboard, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss, header: { EmptyView() }, content: content)
    }

    /// Presents a bottom sheet with a custom header using UIViewController presentation when item is non-nil.
    func presentBottomSheet<Item>(
        item: Binding<Item?>,
        maxHeightRatio: CGFloat = 0.9,
        avoidsKeyboard: Bool = true,
        edgeSwipeBackToDismiss: Bool = true,
        @ViewBuilder header: @escaping () -> some View,
        @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View {
        modifier(BottomSheetPresentItemModifier(item: item, maxHeightRatio: maxHeightRatio, avoidsKeyboard: avoidsKeyboard, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss, header: header, content: content))
    }
}

// MARK: - onChange Compatibility

@available(iOS 15.0, *)
private extension View {
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            onChange(of: value) { newValue in
                action(newValue)
            }
        }
    }
}

// MARK: - Modifier (Bool)

@available(iOS 15.0, *)
struct BottomSheetPresentModifier<SheetHeader: View, SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let maxHeightRatio: CGFloat
    let avoidsKeyboard: Bool
    let edgeSwipeBackToDismiss: Bool
    @ViewBuilder var header: () -> SheetHeader
    @ViewBuilder var content: () -> SheetContent

    @State private var presenter: BottomSheetPresenter<SheetHeader, SheetContent>?

    func body(content: Content) -> some View {
        content
            .onChangeCompat(of: isPresented) { newValue in
                if newValue {
                    presentSheet()
                } else {
                    dismissSheet()
                }
            }
            .onDisappear {
                dismissSheet()
            }
    }

    private func presentSheet() {
        guard presenter == nil else { return }

        let newPresenter = BottomSheetPresenter(
            header: header(),
            content: content(),
            maxHeightRatio: maxHeightRatio,
            avoidsKeyboard: avoidsKeyboard,
            edgeSwipeBackToDismiss: edgeSwipeBackToDismiss,
            onDismiss: {
                isPresented = false
                presenter = nil
            },
        )
        presenter = newPresenter
        newPresenter.present()
    }

    private func dismissSheet() {
        presenter?.dismiss()
    }
}

// MARK: - Modifier (Item)

@available(iOS 15.0, *)
@MainActor
struct BottomSheetPresentItemModifier<Item, SheetHeader: View, SheetContent: View>: ViewModifier {
    @Binding var item: Item?
    let maxHeightRatio: CGFloat
    let avoidsKeyboard: Bool
    let edgeSwipeBackToDismiss: Bool
    @ViewBuilder var header: () -> SheetHeader
    @ViewBuilder var content: (Item) -> SheetContent

    @State private var presenter: BottomSheetPresenter<SheetHeader, SheetContent>?

    func body(content: Content) -> some View {
        content
            .onChangeCompat(of: item != nil) { hasItem in
                if hasItem, let unwrapped = item {
                    presentSheet(with: unwrapped)
                } else {
                    dismissSheet()
                }
            }
            .onDisappear {
                dismissSheet()
            }
    }

    private func presentSheet(with unwrapped: Item) {
        guard presenter == nil else { return }

        let newPresenter = BottomSheetPresenter(
            header: header(),
            content: content(unwrapped),
            maxHeightRatio: maxHeightRatio,
            avoidsKeyboard: avoidsKeyboard,
            edgeSwipeBackToDismiss: edgeSwipeBackToDismiss,
            onDismiss: {
                item = nil
                presenter = nil
            },
        )
        presenter = newPresenter
        newPresenter.present()
    }

    private func dismissSheet() {
        presenter?.dismiss()
    }
}

// MARK: - Presenter

@available(iOS 15.0, *)
@MainActor
final class BottomSheetPresenter<Header: View, Content: View> {
    private var wrapperController: SheetWrapperController<Header, Content>?
    private let header: Header
    private let content: Content
    private let maxHeightRatio: CGFloat
    private let avoidsKeyboard: Bool
    private let edgeSwipeBackToDismiss: Bool
    private let onDismiss: () -> Void

    init(header: Header, content: Content, maxHeightRatio: CGFloat = SheetConstants.maxHeightRatio, avoidsKeyboard: Bool = true, edgeSwipeBackToDismiss: Bool = true, onDismiss: @escaping () -> Void) {
        self.header = header
        self.content = content
        self.maxHeightRatio = maxHeightRatio
        self.avoidsKeyboard = avoidsKeyboard
        self.edgeSwipeBackToDismiss = edgeSwipeBackToDismiss
        self.onDismiss = onDismiss
    }

    func present() {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first

        guard let windowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
                ?? windowScene.windows.first?.rootViewController
        else {
            assertionFailure("BottomSheetPresenter: No window scene or root view controller available")
            return
        }

        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }

        let wrapper = SheetWrapperController(header: header, content: content, maxHeightRatio: maxHeightRatio, avoidsKeyboard: avoidsKeyboard, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss, onDismiss: onDismiss)
        wrapperController = wrapper

        topController.present(wrapper, animated: false)
    }

    func dismiss() {
        wrapperController?.dismissSheet()
    }
}

// MARK: - SheetWrapperController (uses existing BottomSheetController)

@available(iOS 15.0, *)
@MainActor
final class SheetWrapperController<Header: View, Content: View>: UIViewController {
    private let header: Header
    private let content: Content
    private let maxHeightRatio: CGFloat
    private let avoidsKeyboard: Bool
    private let edgeSwipeBackToDismiss: Bool
    private var onDismiss: (() -> Void)?
    private var isDismissing = false

    private let dimView = UIView()
    private var sheetController: BottomSheetController<Header, Content>?
    private var sheetBottomConstraint: NSLayoutConstraint?
    private var keyboardBehavior: KeyboardAvoidingBehavior?

    init(header: Header, content: Content, maxHeightRatio: CGFloat = SheetConstants.maxHeightRatio, avoidsKeyboard: Bool = true, edgeSwipeBackToDismiss: Bool = true, onDismiss: @escaping () -> Void) {
        self.header = header
        self.content = content
        self.maxHeightRatio = maxHeightRatio
        self.avoidsKeyboard = avoidsKeyboard
        self.edgeSwipeBackToDismiss = edgeSwipeBackToDismiss
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // NotificationCenter automatically removes observers on dealloc (iOS 9+).
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDimView()
        setupSheetController()
        if avoidsKeyboard {
            setupKeyboardBehavior()
        }
    }

    private func setupKeyboardBehavior() {
        guard let constraint = sheetBottomConstraint else { return }
        keyboardBehavior = KeyboardAvoidingBehavior()
        keyboardBehavior?.startObserving(bottomConstraint: constraint, view: view)
    }

    private func setupDimView() {
        view.backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let dimTap = UITapGestureRecognizer(target: self, action: #selector(handleDimTap))
        dimView.addGestureRecognizer(dimTap)
    }

    private func setupSheetController() {
        // avoidsKeyboard: false because SheetWrapperController handles keyboard
        let sheet = BottomSheetController(header: header, content: content, maxHeightRatio: maxHeightRatio, avoidsKeyboard: false, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss) { [weak self] in
            self?.finishDismiss()
        }
        // Dim animation is controlled by BottomSheetController via this callback
        sheet.onDragProgressChanged = { [weak self] progress, animated in
            if animated {
                UIView.animate(withDuration: 0.25) {
                    self?.dimView.alpha = 1 - progress
                }
            } else {
                self?.dimView.alpha = 1 - progress
            }
        }

        addChild(sheet)
        view.addSubview(sheet.view)
        sheet.view.translatesAutoresizingMaskIntoConstraints = false

        let bottomConstraint = sheet.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        sheetBottomConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            sheet.view.topAnchor.constraint(equalTo: view.topAnchor),
            sheet.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
        ])

        sheet.didMove(toParent: self)
        sheetController = sheet
    }

    @objc private func handleDimTap() {
        dismissSheet()
    }

    func dismissSheet() {
        guard !isDismissing else { return }
        isDismissing = true
        sheetController?.dismissSheet()
    }

    private func finishDismiss() {
        dismiss(animated: false) { [weak self] in
            self?.onDismiss?()
            self?.onDismiss = nil
        }
    }
}
