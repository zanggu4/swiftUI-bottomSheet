//
//  RadiusToken.swift
//  DesignSystem
//
//  Created by 이현재 on 1/2/26.
//

import SwiftUI

// MARK: - Semantic Radius Token

public enum RadiusToken: Sendable {
    case xxs
    case xs
    case s
    case m
    case l
    case xl
    case xxl
    case full

    private var radius: BaseRadius {
        switch self {
        case .xxs: ._2
        case .xs: ._4
        case .s: ._8
        case .m: ._10
        case .l: ._12
        case .xl: ._18
        case .xxl: ._20
        case .full: ._50percent
        }
    }

    public var value: CGFloat {
        radius.rawValue
    }
}
