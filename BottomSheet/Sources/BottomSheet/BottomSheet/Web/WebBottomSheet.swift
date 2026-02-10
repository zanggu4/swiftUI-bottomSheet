//
//  WebBottomSheet.swift
//  BottomSheet
//
//  WebView 기반 바텀시트 - Controller 및 Template
//
//  ## HTML에서 사용 가능한 JavaScript API
//
//  ### dismiss() - 바텀시트 닫기
//  ```javascript
//  dismiss()
//  ```
//
//  ### action - 커스텀 액션 전달
//  ```javascript
//  webkit.messageHandlers.action.postMessage({
//      name: "confirm",
//      data: { id: 123 }
//  })
//  ```
//

import SwiftUI
import UIKit
import WebKit

// MARK: - Action

/// 웹 바텀시트 액션 데이터
public struct WebSheetAction {
    public let name: String
    public let data: Any?
}

// MARK: - Controller

/// WKWebView를 사용한 바텀시트 컨트롤러
@MainActor
public final class WebBottomSheetController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    private var webView: WKWebView?
    private var dimView: UIView!
    private var loadingIndicator: UIActivityIndicatorView!
    private var dismissHandler: (() -> Void)?
    private var actionHandler: ((WebSheetAction) -> Void)?
    private var linkActionHandler: ((String?) -> Void)?
    private var pendingHTML: String?
    private var pendingURL: URL?
    private var isDismissing = false

    public init(
        dismissHandler: @escaping () -> Void,
        actionHandler: ((WebSheetAction) -> Void)? = nil,
        linkActionHandler: ((String?) -> Void)? = nil
    ) {
        self.dismissHandler = dismissHandler
        self.actionHandler = actionHandler
        self.linkActionHandler = linkActionHandler
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        MainActor.assumeIsolated {
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "dismiss")
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: "action")
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupDimView()
        setupLoadingIndicator()
        setupWebView()

        if let html = pendingHTML {
            webView?.loadHTMLString(html, baseURL: Bundle.module.bundleURL)
            pendingHTML = nil
        } else if let url = pendingURL {
            webView?.load(URLRequest(url: url))
            pendingURL = nil
        }
    }

    private func setupDimView() {
        dimView = UIView(frame: view.bounds)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0)
        view.addSubview(dimView)

        UIView.animate(withDuration: 0.3) {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(tapGesture)
    }

    @objc private func dimTapped() {
        dismissSheet()
    }

    private func dismissSheet() {
        guard !isDismissing else { return }
        isDismissing = true

        UIView.animate(withDuration: 0.3) {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: false) {
                self.dismissHandler?()
            }
        }
    }

    /// 외부에서 애니메이션과 함께 닫기
    public func dismissWithAnimation() {
        guard !isDismissing else { return }
        webView?.evaluateJavaScript("dismiss()") { _, _ in }
    }

    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self, name: "dismiss")
        contentController.add(self, name: "action")
        config.userContentController = contentController

        let wv = WKWebView(frame: view.bounds, configuration: config)
        wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.scrollView.backgroundColor = .clear
        wv.scrollView.isScrollEnabled = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        wv.alpha = 0
        wv.navigationDelegate = self

        #if DEBUG
            if #available(iOS 16.4, *) {
                wv.isInspectable = true
            }
        #endif

        view.backgroundColor = .clear
        view.addSubview(wv)
        webView = wv
    }

    // MARK: - WKNavigationDelegate

    public func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()

        UIView.animate(withDuration: 0.2) {
            self.webView?.alpha = 1
        }
    }

    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if navigationAction.navigationType == .linkActivated {
            let url = navigationAction.request.url?.absoluteString
            linkActionHandler?(url)
            return .cancel
        }
        return .allow
    }

    /// HTML 문자열 로드
    public func loadHTML(_ html: String) {
        if let webView {
            webView.loadHTMLString(html, baseURL: Bundle.module.bundleURL)
        } else {
            pendingHTML = html
        }
    }

    /// URL 로드
    public func loadURL(_ url: URL) {
        if let webView {
            webView.load(URLRequest(url: url))
        } else {
            pendingURL = url
        }
    }

    /// content를 템플릿에 삽입하여 로드
    public func loadContent(
        _ content: WebBottomSheetContent,
        header: WebBottomSheetHeader? = nil,
        fontStyle: FontStyle = .body2R22,
        textColor: UIColor = .black,
    ) {
        let html = WebBottomSheetTemplate.html(
            header: header,
            content: content,
            fontWeight: fontStyle.weight.value,
            fontSize: fontStyle.size,
            textColor: textColor,
        )
        loadHTML(html)
    }

    // MARK: - WKScriptMessageHandler

    public nonisolated func userContentController(
        _: WKUserContentController,
        didReceive message: WKScriptMessage,
    ) {
        Task { @MainActor in
            switch message.name {
            case "dismiss":
                self.dismissSheet()
            case "action":
                if let body = message.body as? [String: Any],
                   let name = body["name"] as? String
                {
                    self.actionHandler?(WebSheetAction(name: name, data: body["data"]))
                }
            default:
                break
            }
        }
    }
}
