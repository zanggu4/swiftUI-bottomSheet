//
//  WebBottomSheetViews.swift
//  BottomSheet
//
//  Overlay용 SwiftUI View 및 UIViewRepresentable
//

import SwiftUI
import WebKit

// MARK: - Overlay View

struct WebBottomSheetOverlayView: View {
    let header: WebBottomSheetHeader?
    let content: WebBottomSheetContent
    let fontStyle: FontStyle
    let textColor: UIColor
    @Binding var dismissTrigger: Bool
    let onDismiss: () -> Void
    let onAction: ((WebSheetAction) -> Void)?
    let onLinkTap: ((String?) -> Void)?

    @State private var dimOpacity: Double = 0
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            Color.black
                .opacity(dimOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissTrigger = true
                }

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }

            WebBottomSheetWebView(
                header: header,
                content: content,
                fontStyle: fontStyle,
                textColor: textColor,
                dismissTrigger: $dismissTrigger,
                onDismiss: onDismiss,
                onAction: onAction,
                onLinkTap: onLinkTap,
                onLoadFinished: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isLoading = false
                    }
                },
            )
            .opacity(isLoading ? 0 : 1)
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                dimOpacity = 0.4
            }
        }
        .onChange(of: dismissTrigger) { trigger in
            if trigger {
                withAnimation(.easeOut(duration: 0.3)) {
                    dimOpacity = 0
                }
            }
        }
    }
}

// MARK: - Custom WKWebView

final class BottomSheetWKWebView: WKWebView {
    var onTraitChange: ((UITraitCollection) -> Void)?

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            onTraitChange?(traitCollection)
        }
    }
}

// MARK: - WebView (UIViewRepresentable)

struct WebBottomSheetWebView: UIViewRepresentable {
    let header: WebBottomSheetHeader?
    let content: WebBottomSheetContent
    let fontStyle: FontStyle
    let textColor: UIColor
    @Binding var dismissTrigger: Bool
    let onDismiss: () -> Void
    let onAction: ((WebSheetAction) -> Void)?
    let onLinkTap: ((String?) -> Void)?
    let onLoadFinished: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss, onAction: onAction, onLinkTap: onLinkTap, onLoadFinished: onLoadFinished)
    }

    func makeUIView(context: Context) -> BottomSheetWKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "dismiss")
        contentController.add(context.coordinator, name: "action")
        config.userContentController = contentController

        let webView = BottomSheetWKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = context.coordinator
        #if DEBUG
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            }
        #endif

        webView.onTraitChange = { _ in
            let html = WebBottomSheetTemplate.html(
                header: header,
                content: content,
                fontWeight: fontStyle.weight.value,
                fontSize: fontStyle.size,
                textColor: textColor,
            )
            webView.loadHTMLString(html, baseURL: Bundle.module.bundleURL)
        }

        context.coordinator.webView = webView

        let html = WebBottomSheetTemplate.html(
            header: header,
            content: content,
            fontWeight: fontStyle.weight.value,
            fontSize: fontStyle.size,
            textColor: textColor,
        )
        webView.loadHTMLString(html, baseURL: Bundle.module.bundleURL)

        return webView
    }

    func updateUIView(_ webView: BottomSheetWKWebView, context: Context) {
        if dismissTrigger, !context.coordinator.isDismissing {
            context.coordinator.isDismissing = true
            webView.evaluateJavaScript("dismiss()") { _, _ in }
        }
    }

    static func dismantleUIView(_ webView: BottomSheetWKWebView, coordinator _: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "dismiss")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "action")
    }

    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        let onDismiss: () -> Void
        let onAction: ((WebSheetAction) -> Void)?
        let onLinkTap: ((String?) -> Void)?
        let onLoadFinished: () -> Void
        var webView: BottomSheetWKWebView?
        var isDismissing = false

        init(
            onDismiss: @escaping () -> Void,
            onAction: ((WebSheetAction) -> Void)?,
            onLinkTap: ((String?) -> Void)?,
            onLoadFinished: @escaping () -> Void
        ) {
            self.onDismiss = onDismiss
            self.onAction = onAction
            self.onLinkTap = onLinkTap
            self.onLoadFinished = onLoadFinished
        }

        func webView(_: WKWebView, didFinish _: WKNavigation!) {
            onLoadFinished()
        }

        func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if navigationAction.navigationType == .linkActivated {
                let url = navigationAction.request.url?.absoluteString
                onLinkTap?(url)
                return .cancel
            }
            return .allow
        }

        func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "dismiss":
                onDismiss()
            case "action":
                if let body = message.body as? [String: Any],
                   let name = body["name"] as? String
                {
                    let data = body["data"]
                    onAction?(WebSheetAction(name: name, data: data))
                }
            default:
                break
            }
        }
    }
}
