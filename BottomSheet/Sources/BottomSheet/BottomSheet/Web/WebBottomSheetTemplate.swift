//
//  WebBottomSheetTemplate.swift
//  BottomSheet
//
//  바텀시트 HTML 템플릿 생성
//

import UIKit

/// 바텀시트 HTML 템플릿
///
/// ## 템플릿 플레이스홀더
/// HTML 템플릿에서 사용 가능한 플레이스홀더 목록:
///
/// | 플레이스홀더 | 설명 |
/// |------------|------|
/// | `{{HEADER}}` | 헤더 HTML |
/// | `{{CONTENT}}` | 컨텐츠 HTML |
/// | `{{FONT_WEIGHT}}` | 폰트 굵기 (100-900) |
/// | `{{FONT_SIZE}}` | 폰트 크기 (px) |
/// | `{{TEXT_COLOR}}` | 텍스트 색상 (hex) |
/// | `{{SHEET_BACKGROUND_COLOR}}` | 시트 배경색 (hex) |
///
public enum WebBottomSheetTemplate {
    public enum Locale {
        case korean
        case japanese
    }

    /// header와 content를 포함한 완전한 HTML 반환
    public static func html(
        header: WebBottomSheetHeader? = nil,
        content: WebBottomSheetContent,
        fontWeight: Int = 400,
        fontSize: CGFloat = 16,
        textColor: UIColor = .black,
        sheetBackgroundColor: UIColor? = nil,
        locale: Locale = .korean,
    ) -> String {
        let headerHTML = header.map {
            """
            <div class="header" id="header">
                \($0.html)
            </div>
            """
        } ?? ""

        let templateName = locale == .japanese ? "WebBottomSheet_JP" : "WebBottomSheet"
        let convertedContent = applyDarkModeIfNeeded(to: content)
        let backgroundColor = (sheetBackgroundColor ?? UIColorChip.gray0).hexString

        guard let url = Bundle.module.url(forResource: templateName, withExtension: "html") else {
            assertionFailure("Template file not found: \(templateName).html")
            return "<html><body>\(convertedContent.html)</body></html>"
        }

        guard let template = try? String(contentsOf: url, encoding: .utf8) else {
            assertionFailure("Failed to read template: \(templateName).html")
            return "<html><body>\(convertedContent.html)</body></html>"
        }

        return template
            .replacingOccurrences(of: "{{HEADER}}", with: headerHTML)
            .replacingOccurrences(of: "{{CONTENT}}", with: convertedContent.html)
            .replacingOccurrences(of: "{{FONT_WEIGHT}}", with: "\(fontWeight)")
            .replacingOccurrences(of: "{{FONT_SIZE}}", with: "\(fontSize)")
            .replacingOccurrences(of: "{{TEXT_COLOR}}", with: textColor.hexString)
            .replacingOccurrences(of: "{{SHEET_BACKGROUND_COLOR}}", with: backgroundColor)
    }

    // MARK: - Private

    /// 다크모드일 경우 HTML 컨텐츠 변환
    private static func applyDarkModeIfNeeded(to content: WebBottomSheetContent) -> WebBottomSheetContent {
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark

        switch content {
        case let .pointDescription(html, point, confirmButton, pointStyle):
            return .pointDescription(
                html: isDarkMode ? HTMLDarkModeConverter.convert(html ?? "") : html,
                point: isDarkMode ? HTMLDarkModeConverter.convert(point ?? "") : point,
                confirmButton: confirmButton,
                pointStyle: pointStyle,
            )

        case let .default(html):
            return .default(html: isDarkMode ? HTMLDarkModeConverter.convert(html) : html)

        case let .custom(html):
            return .custom(html: isDarkMode ? HTMLDarkModeConverter.convert(html) : html)
        }
    }
}
