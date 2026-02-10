//
//  WebBottomSheetModifiers.swift
//  BottomSheet
//
//  WebBottomSheet View Extension 및 Modifiers
//

import SwiftUI

// MARK: - View Extension

public extension View {
    // MARK: Overlay Style

    /// Overlay 방식 WebView 바텀시트 (Bool 바인딩)
    func overlayWebSheet(
        isPresented: Binding<Bool>,
        header: WebBottomSheetHeader? = nil,
        content: WebBottomSheetContent,
        fontStyle: FontStyle = .body2R22,
        textColor: UIColor = UIColorChip.gray90,
        onAction: ((WebSheetAction) -> Void)? = nil,
        onLinkTap: ((String?) -> Void)? = nil,
    ) -> some View {
        modifier(WebBottomSheetOverlayModifier(
            isPresented: isPresented,
            header: header,
            content: content,
            fontStyle: fontStyle,
            textColor: textColor,
            onAction: onAction,
            onLinkTap: onLinkTap,
        ))
    }

    /// Overlay 방식 WebView 바텀시트 (Item 바인딩)
    func overlayWebSheet<Item>(
        item: Binding<Item?>,
        header: WebBottomSheetHeader? = nil,
        content: @escaping (Item) -> WebBottomSheetContent,
        fontStyle: FontStyle = .body2R22,
        textColor: UIColor = UIColorChip.gray90,
        onAction: ((WebSheetAction) -> Void)? = nil,
        onLinkTap: ((String?) -> Void)? = nil
    ) -> some View {
        modifier(WebBottomSheetOverlayItemModifier(
            item: item,
            header: header,
            content: content,
            fontStyle: fontStyle,
            textColor: textColor,
            onAction: onAction,
            onLinkTap: onLinkTap,
        ))
    }

    // MARK: Present Style

    /// Present 방식 WebView 바텀시트 (Bool 바인딩)
    func webSheet(
        isPresented: Binding<Bool>,
        header: WebBottomSheetHeader? = nil,
        content: WebBottomSheetContent,
        fontStyle: FontStyle = .body2R22,
        textColor: UIColor = UIColorChip.gray90,
        onAction: ((WebSheetAction) -> Void)? = nil,
        onLinkTap: ((String?) -> Void)? = nil,
    ) -> some View {
        background(
            WebBottomSheetRepresentable(
                isPresented: isPresented,
                header: header,
                content: content,
                fontStyle: fontStyle,
                textColor: textColor,
                onAction: onAction,
                onLinkTap: onLinkTap,
            ),
        )
    }

    /// Present 방식 WebView 바텀시트 (Item 바인딩)
    func webSheet<Item>(
        item: Binding<Item?>,
        header: WebBottomSheetHeader? = nil,
        content: @escaping (Item) -> WebBottomSheetContent,
        fontStyle: FontStyle = .body2R22,
        textColor: UIColor = UIColorChip.gray90,
        onAction: ((WebSheetAction) -> Void)? = nil,
        onLinkTap: ((String?) -> Void)? = nil
    ) -> some View {
        background(
            WebBottomSheetItemRepresentable(
                item: item,
                header: header,
                content: content,
                fontStyle: fontStyle,
                textColor: textColor,
                onAction: onAction,
                onLinkTap: onLinkTap,
            ),
        )
    }
}

// MARK: - Overlay Modifier (Bool)

struct WebBottomSheetOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    let header: WebBottomSheetHeader?
    let content: WebBottomSheetContent
    let fontStyle: FontStyle
    let textColor: UIColor
    let onAction: ((WebSheetAction) -> Void)?
    let onLinkTap: ((String?) -> Void)?

    @State private var showSheet = false
    @State private var dismissTrigger = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if showSheet {
                    WebBottomSheetOverlayView(
                        header: header,
                        content: self.content,
                        fontStyle: fontStyle,
                        textColor: textColor,
                        dismissTrigger: $dismissTrigger,
                        onDismiss: {
                            isPresented = false
                            showSheet = false
                        },
                        onAction: onAction,
                        onLinkTap: onLinkTap,
                    )
                }
            }
            .onChange(of: isPresented) { newValue in
                if newValue {
                    dismissTrigger = false
                    showSheet = true
                } else if showSheet {
                    dismissTrigger = true
                }
            }
    }
}

// MARK: - Overlay Modifier (Item)

struct WebBottomSheetOverlayItemModifier<Item>: ViewModifier {
    @Binding var item: Item?
    let header: WebBottomSheetHeader?
    let content: (Item) -> WebBottomSheetContent
    let fontStyle: FontStyle
    let textColor: UIColor
    let onAction: ((WebSheetAction) -> Void)?
    let onLinkTap: ((String?) -> Void)?

    @State private var showSheet = false
    @State private var dismissTrigger = false
    @State private var capturedItem: Item?

    func body(content: Content) -> some View {
        content
            .overlay {
                if showSheet, let captured = capturedItem {
                    WebBottomSheetOverlayView(
                        header: header,
                        content: self.content(captured),
                        fontStyle: fontStyle,
                        textColor: textColor,
                        dismissTrigger: $dismissTrigger,
                        onDismiss: {
                            item = nil
                            showSheet = false
                            capturedItem = nil
                        },
                        onAction: onAction,
                        onLinkTap: onLinkTap,
                    )
                }
            }
            .onChange(of: item != nil) { hasItem in
                if hasItem, let unwrapped = item {
                    dismissTrigger = false
                    capturedItem = unwrapped
                    showSheet = true
                } else if showSheet {
                    dismissTrigger = true
                }
            }
    }
}

// MARK: - Present Representable (Bool)

struct WebBottomSheetRepresentable: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let header: WebBottomSheetHeader?
    let content: WebBottomSheetContent
    let fontStyle: FontStyle
    let textColor: UIColor
    let onAction: ((WebSheetAction) -> Void)?
    let onLinkTap: ((String?) -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context _: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            if uiViewController.presentedViewController == nil {
                let controller = WebBottomSheetController(
                    dismissHandler: { isPresented = false },
                    actionHandler: onAction,
                    linkActionHandler: onLinkTap,
                )
                context.coordinator.controller = controller
                controller.loadContent(content, header: header, fontStyle: fontStyle, textColor: textColor)
                uiViewController.present(controller, animated: false)
            }
        } else {
            if let controller = context.coordinator.controller,
               uiViewController.presentedViewController != nil
            {
                controller.dismissWithAnimation()
                context.coordinator.controller = nil
            }
        }
    }

    class Coordinator {
        var controller: WebBottomSheetController?
    }
}

// MARK: - Present Representable (Item)

struct WebBottomSheetItemRepresentable<Item>: UIViewControllerRepresentable {
    @Binding var item: Item?
    let header: WebBottomSheetHeader?
    let content: (Item) -> WebBottomSheetContent
    let fontStyle: FontStyle
    let textColor: UIColor
    let onAction: ((WebSheetAction) -> Void)?
    let onLinkTap: ((String?) -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context _: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let currentItem = item {
            if uiViewController.presentedViewController == nil {
                context.coordinator.capturedItem = currentItem
                let controller = WebBottomSheetController(
                    dismissHandler: { item = nil },
                    actionHandler: onAction,
                    linkActionHandler: onLinkTap,
                )
                context.coordinator.controller = controller
                controller.loadContent(content(currentItem), header: header, fontStyle: fontStyle, textColor: textColor)
                uiViewController.present(controller, animated: false)
            }
        } else {
            if let controller = context.coordinator.controller,
               uiViewController.presentedViewController != nil
            {
                controller.dismissWithAnimation()
                context.coordinator.controller = nil
                context.coordinator.capturedItem = nil
            }
        }
    }

    class Coordinator {
        var capturedItem: Item?
        var controller: WebBottomSheetController?
    }
}
