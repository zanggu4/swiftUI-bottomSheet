//
//  WebBottomSheetHeader.swift
//  BottomSheet
//
//  바텀시트 헤더 템플릿
//

import UIKit

/// 바텀시트 헤더 템플릿
public enum WebBottomSheetHeader {
    /// 중앙 타이틀 + 우측 닫기 버튼
    case centerTitle(
        title: String,
        titleColor: UIColor? = nil,
        closeIconColor: UIColor? = nil,
        dividerColor: UIColor? = nil,
    )
    /// 커스텀 HTML
    case custom(html: String)

    // MARK: - Constants

    private static let closeIconBase64 = "PHN2ZyB3aWR0aD0iMTQiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxNCAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEgMUwxMyAxMyIgc3Ryb2tlPSIjNTg2MDY2IiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIvPgo8cGF0aCBkPSJNMTMgMUwxIDEzIiBzdHJva2U9IiM1ODYwNjYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8+Cjwvc3ZnPgo="

    // MARK: - HTML Output

    public var html: String {
        switch self {
        case let .centerTitle(title, titleColor, closeIconColor, dividerColor):
            let actualTitleColor = (titleColor ?? UIColorChip.gray80).hexString
            let actualCloseIconColor = (closeIconColor ?? UIColor.Icon.navigationBar).hexString
            let actualDividerColor = (dividerColor ?? UIColorChip.gray10).hexString

            return """
            <style>
                .header-wrap { position: relative; width: 100%; }
                .header-title {
                    text-align: center;
                    padding: 23px 0 10px;
                    font-weight: 600;
                    font-size: 16px;
                    line-height: 16px;
                    color: \(actualTitleColor);
                }
                .close-btn {
                    position: absolute;
                    top: 20px;
                    right: 22px;
                    padding: 6px;
                    margin: 0;
                    background: none;
                    border: none;
                }
                .close-icon {
                    width: 14px;
                    height: 14px;
                    background-color: \(actualCloseIconColor);
                    -webkit-mask-image: url('data:image/svg+xml;base64,\(Self.closeIconBase64)');
                    -webkit-mask-size: contain;
                    -webkit-mask-repeat: no-repeat;
                    mask-image: url('data:image/svg+xml;base64,\(Self.closeIconBase64)');
                    mask-size: contain;
                    mask-repeat: no-repeat;
                }
                .header-divider {
                    border: none;
                    border-top: 1px solid \(actualDividerColor);
                    margin: 0 16px;
                }
            </style>
            <div class="header-wrap">
                <div class="header-title">\(title.util.htmlEscaped)</div>
                <button class="close-btn" onclick="dismiss()">
                    <div class="close-icon"></div>
                </button>
            </div>
            <hr class="header-divider">
            """
        case let .custom(html):
            return html
        }
    }
}
