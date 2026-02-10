//
//  SpacingToken.swift
//  DesignSystem
//
//  Created by 이현재 on 1/2/26.
//

import SwiftUI

public enum SpacingToken {
    // MARK: - Default

    case spacing01
    case spacing02
    case spacing04
    case spacing06
    case spacing08
    case spacing10
    case spacing12
    case spacing13
    case spacing14
    case spacing16
    case spacing18
    case spacing20
    case spacing24
    case spacing30
    case spacing40
    case spacing50
    case spacing60
    case spacing100

    public var value: CGFloat {
        switch self {
        case .spacing01: BaseSpacing._1.rawValue
        case .spacing02: BaseSpacing._2.rawValue
        case .spacing04: BaseSpacing._4.rawValue
        case .spacing06: BaseSpacing._6.rawValue
        case .spacing08: BaseSpacing._8.rawValue
        case .spacing10: BaseSpacing._10.rawValue
        case .spacing12: BaseSpacing._12.rawValue
        case .spacing13: BaseSpacing._13.rawValue
        case .spacing14: BaseSpacing._14.rawValue
        case .spacing16: BaseSpacing._16.rawValue
        case .spacing18: BaseSpacing._18.rawValue
        case .spacing20: BaseSpacing._20.rawValue
        case .spacing24: BaseSpacing._24.rawValue
        case .spacing30: BaseSpacing._30.rawValue
        case .spacing40: BaseSpacing._40.rawValue
        case .spacing50: BaseSpacing._50.rawValue
        case .spacing60: BaseSpacing._60.rawValue
        case .spacing100: BaseSpacing._100.rawValue
        }
    }

    // MARK: - SpacingY

    public enum SpacingY {
        case screenBottom
        case listBottom
        case sectionPrimary
        case sectionSecondary
        case navigationBar

        public var value: CGFloat {
            switch self {
            case .screenBottom: BaseSpacing._60.rawValue
            case .listBottom: BaseSpacing._100.rawValue
            case .sectionPrimary: BaseSpacing._30.rawValue
            case .sectionSecondary: BaseSpacing._22.rawValue
            case .navigationBar: BaseSpacing._13.rawValue
            }
        }
    }

    // MARK: - SpacingX

    public enum SpacingX {
        case global

        public var value: CGFloat {
            switch self {
            case .global: BaseSpacing._16.rawValue
            }
        }
    }

    // MARK: - Padding

    public enum Padding {
        case input
        case productContainer
        case product
        case modalPopup

        public var value: CGFloat {
            switch self {
            case .input: BaseSpacing._20.rawValue
            case .productContainer: BaseSpacing._8.rawValue
            case .product: BaseSpacing._8.rawValue
            case .modalPopup: BaseSpacing._30.rawValue
            }
        }
    }
}
