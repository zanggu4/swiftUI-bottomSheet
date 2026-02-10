//
//  FontWeight.swift
//  DesignSystem
//
//  Created by 이현재 on 2025/08/20.
//  Copyright © 2025 WAUG. All rights reserved.
//

import Foundation

public enum FontWeight: String {
    case thin
    case semiBold
    case regular
    case medium
    case light
    case heavy
    case extraLight
    case extraBold
    case bold

    ///  숫자값, HTML에서 사용
    public var value: Int {
        switch self {
        case .thin:
            100
        case .extraLight:
            200
        case .light:
            300
        case .regular:
            400
        case .medium:
            500
        case .semiBold:
            600
        case .bold:
            700
        case .extraBold:
            800
        case .heavy:
            900
        }
    }

    public var rawValue: String {
        suitFontName
    }

    private var suitFontName: String {
        switch self {
        case .thin:
            "SUIT-Thin"
        case .semiBold:
            "SUIT-SemiBold"
        case .regular:
            "SUIT-Regular"
        case .medium:
            "SUIT-Medium"
        case .light:
            "SUIT-Light"
        case .heavy:
            "SUIT-Heavy"
        case .extraLight:
            "SUIT-ExtraLight"
        case .extraBold:
            "SUIT-ExtraBold"
        case .bold:
            "SUIT-Bold"
        }
    }

    private var pretendardFontName: String {
        switch self {
        case .thin:
            "PretendardJP-Thin"
        case .semiBold:
            "PretendardJP-SemiBold"
        case .regular:
            "PretendardJP-Regular"
        case .medium:
            "PretendardJP-Medium"
        case .light:
            "PretendardJP-Light"
        case .heavy:
            "PretendardJP-Heavy"
        case .extraLight:
            "PretendardJP-ExtraLight"
        case .extraBold:
            "PretendardJP-ExtraBold"
        case .bold:
            "PretendardJP-Bold"
        }
    }
}
