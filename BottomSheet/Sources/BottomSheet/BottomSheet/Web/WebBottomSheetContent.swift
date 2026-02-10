//
//  WebBottomSheetContent.swift
//  BottomSheet
//
//  바텀시트 컨텐츠 템플릿
//

import UIKit

// MARK: - Styles

/// 포인트 박스 스타일
public struct PointStyle: Sendable {
    public let backgroundColor: UIColor?
    public let borderColor: UIColor?
    public let textColor: UIColor?

    public init(
        backgroundColor: UIColor? = nil,
        borderColor: UIColor? = nil,
        textColor: UIColor? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.textColor = textColor
    }

    public static let `default` = PointStyle()
}

/// 확인 버튼 스타일
public struct ConfirmButtonStyle: Sendable {
    public let title: String
    public let color: UIColor?
    public let textColor: UIColor?

    public init(
        title: String = "확인",
        color: UIColor? = nil,
        textColor: UIColor? = nil
    ) {
        self.title = title
        self.color = color
        self.textColor = textColor
    }

    public static let `default` = ConfirmButtonStyle()
}

// MARK: - Content

/// 바텀시트 컨텐츠 템플릿
public enum WebBottomSheetContent {
    /// 기본 HTML
    case `default`(html: String)
    /// 하단 포인트 설명이 포함된 항목
    case pointDescription(
        html: String?,
        point: String?,
        confirmButton: ConfirmButtonStyle? = nil,
        pointStyle: PointStyle = .default,
    )
    /// 커스텀 HTML
    case custom(html: String)

    // MARK: - HTML Output

    public var html: String {
        switch self {
        case let .default(html):
            return """
            <div style="padding: 20px">\(html)</div>
            """

        case let .pointDescription(html, point, confirmButton, pointStyle):
            let bgColor = (pointStyle.backgroundColor ?? UIColorChip.pink10).hexString
            let borderColor = (pointStyle.borderColor ?? UIColorChip.pink20).hexString
            let textColor = (pointStyle.textColor ?? UIColorChip.pink50).hexString

            guard let point else {
                return """
                <div style="padding: 20px">\(html ?? "")</div>
                """
            }

            let buttonHTML: String
            if let button = confirmButton {
                let buttonColor = (button.color ?? UIColorChip.gray100).hexString
                let buttonTextColor = (button.textColor ?? UIColorChip.gray0).hexString
                buttonHTML = """
                <button onclick="webkit.messageHandlers.action.postMessage({name: 'confirm'})" style="
                    width: 100%;
                    padding: 16px;
                    margin-top: 20px;
                    border: none;
                    border-radius: 12px;
                    background: \(buttonColor);
                    color: \(buttonTextColor);
                    font-size: 16px;
                    font-weight: 600;
                    cursor: pointer;
                ">
                    \(button.title)
                </button>
                """
            } else {
                buttonHTML = ""
            }

            return """
            <div style="padding: 20px">
                \(html ?? "")
                <div style="
                    width: 100%;
                    padding: 16px 20px;
                    background-color: \(bgColor);
                    border-radius: 12px;
                    border: 1px solid \(borderColor);
                    color: \(textColor);
                    box-sizing: border-box;
                    margin-top: 16px;
                ">
                    \(point)
                </div>
                \(buttonHTML)
            </div>
            """

        case let .custom(html):
            return html
        }
    }
}
