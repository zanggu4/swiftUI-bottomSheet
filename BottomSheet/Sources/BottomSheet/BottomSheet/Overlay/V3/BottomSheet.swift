//
//  BottomSheet.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  A SwiftUI bottom sheet component with UIKit scroll handling.
//

import SwiftUI

// MARK: - View Modifier

@available(iOS 15.0, *)
public extension View {
    /// Presents a bottom sheet when the binding is true.
    func overlaySheet(
        isPresented: Binding<Bool>,
        maxHeightRatio: CGFloat = 0.9,
        avoidsKeyboard: Bool = true,
        edgeSwipeBackToDismiss: Bool = true,
        @ViewBuilder content: @escaping () -> some View,
    ) -> some View {
        modifier(BottomSheetModifier(isPresented: isPresented, maxHeightRatio: maxHeightRatio, avoidsKeyboard: avoidsKeyboard, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss, content: content))
    }

    /// Presents a bottom sheet when the item is non-nil.
    func overlaySheet<Item>(
        item: Binding<Item?>,
        maxHeightRatio: CGFloat = 0.9,
        avoidsKeyboard: Bool = true,
        edgeSwipeBackToDismiss: Bool = true,
        @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View {
        modifier(BottomSheetItemModifier(item: item, maxHeightRatio: maxHeightRatio, avoidsKeyboard: avoidsKeyboard, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss, content: content))
    }
}

// MARK: - Modifier (Bool)

@available(iOS 15.0, *)
struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let maxHeightRatio: CGFloat
    let avoidsKeyboard: Bool
    let edgeSwipeBackToDismiss: Bool
    @ViewBuilder var content: () -> SheetContent

    @State private var showSheet = false
    @State private var dismissTrigger = false

    func body(content: Content) -> some View {
        ZStack {
            content
                .zIndex(1)
            if showSheet {
                BottomSheetView(
                    content: self.content,
                    maxHeightRatio: maxHeightRatio,
                    avoidsKeyboard: avoidsKeyboard,
                    edgeSwipeBackToDismiss: edgeSwipeBackToDismiss,
                    dismissTrigger: $dismissTrigger,
                    onDismiss: {
                        isPresented = false
                        showSheet = false
                    },
                )
                .zIndex(10)
            }
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                showSheet = true
            } else if showSheet {
                // Trigger dismiss animation instead of immediate removal
                dismissTrigger = true
            }
        }
    }
}

// MARK: - Modifier (Item)

@available(iOS 15.0, *)
struct BottomSheetItemModifier<Item, SheetContent: View>: ViewModifier {
    @Binding var item: Item?
    let maxHeightRatio: CGFloat
    let avoidsKeyboard: Bool
    let edgeSwipeBackToDismiss: Bool
    @ViewBuilder var content: (Item) -> SheetContent

    @State private var showSheet = false
    @State private var dismissTrigger = false
    @State private var capturedItem: Item?

    func body(content: Content) -> some View {
        ZStack {
            content
            if showSheet, let captured = capturedItem {
                BottomSheetView(
                    content: { self.content(captured) },
                    maxHeightRatio: maxHeightRatio,
                    avoidsKeyboard: avoidsKeyboard,
                    edgeSwipeBackToDismiss: edgeSwipeBackToDismiss,
                    dismissTrigger: $dismissTrigger,
                    onDismiss: {
                        item = nil
                        showSheet = false
                        capturedItem = nil
                    },
                )
            }
        }
        .onChange(of: item != nil) { hasItem in
            if hasItem, let unwrapped = item {
                capturedItem = unwrapped
                showSheet = true
            } else if showSheet {
                dismissTrigger = true
            }
        }
    }
}

// MARK: - BottomSheetView

/// A bottom sheet overlay that can be dismissed by dragging down or tapping the dimmed background.
@available(iOS 15.0, *)
public struct BottomSheetView<Content: View>: View {
    let content: () -> Content
    let maxHeightRatio: CGFloat
    let avoidsKeyboard: Bool
    let edgeSwipeBackToDismiss: Bool
    @Binding var dismissTrigger: Bool
    let onDismiss: () -> Void

    @State private var dragProgress: CGFloat = 1 // Start hidden

    public init(
        @ViewBuilder content: @escaping () -> Content,
        maxHeightRatio: CGFloat = 0.9,
        avoidsKeyboard: Bool = true,
        edgeSwipeBackToDismiss: Bool = true,
        dismissTrigger: Binding<Bool>,
        onDismiss: @escaping () -> Void
    ) {
        self.content = content
        self.maxHeightRatio = maxHeightRatio
        self.avoidsKeyboard = avoidsKeyboard
        self.edgeSwipeBackToDismiss = edgeSwipeBackToDismiss
        _dismissTrigger = dismissTrigger
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // Dim overlay (SwiftUI)
            Color.black
                .opacity(0.4 * (1 - dragProgress))
                .animation(.easeOut(duration: 0.25), value: dragProgress)
                .onTapGesture {
                    dragProgress = 1
                    dismissTrigger = true
                }

            // Sheet (UIKit)
            SheetViewController(
                content: content,
                maxHeightRatio: maxHeightRatio,
                avoidsKeyboard: avoidsKeyboard,
                edgeSwipeBackToDismiss: edgeSwipeBackToDismiss,
                onDismiss: onDismiss,
                onDragProgressChanged: { progress, animated in
                    // Dispatch to avoid "Modifying state during view update" warning
                    DispatchQueue.main.async {
                        if animated {
                            withAnimation(.easeOut(duration: 0.25)) {
                                dragProgress = progress
                            }
                        } else {
                            dragProgress = progress
                        }
                    }
                },
                dismissTrigger: $dismissTrigger,
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - SheetViewController (UIViewControllerRepresentable)

@available(iOS 15.0, *)
struct SheetViewController<Content: View>: UIViewControllerRepresentable {
    let content: () -> Content
    let maxHeightRatio: CGFloat
    let avoidsKeyboard: Bool
    let edgeSwipeBackToDismiss: Bool
    let onDismiss: () -> Void
    let onDragProgressChanged: (CGFloat, Bool) -> Void
    @Binding var dismissTrigger: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context _: Context) -> BottomSheetController<Content> {
        let vc = BottomSheetController(content: content(), maxHeightRatio: maxHeightRatio, avoidsKeyboard: avoidsKeyboard, edgeSwipeBackToDismiss: edgeSwipeBackToDismiss, onDismiss: onDismiss)
        vc.onDragProgressChanged = onDragProgressChanged
        return vc
    }

    func updateUIViewController(_ uiViewController: BottomSheetController<Content>, context: Context) {
        if dismissTrigger, !context.coordinator.isDismissing {
            context.coordinator.isDismissing = true
            // Dispatch to avoid "Modifying state during view update" warning
            DispatchQueue.main.async {
                dismissTrigger = false
            }
            uiViewController.dismissSheet()
        }
    }

    class Coordinator {
        var isDismissing = false
    }
}
