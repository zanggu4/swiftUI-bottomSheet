//
//  FontStyle.swift
//  UIComponents
//
//  Created by 이현재 on 2023/03/13.
//

import UIKit

public enum FontStyle: Equatable, Hashable {
    case header0
    case header1
    case title0
    case title1
    case title2B
    case title2Sb
    case title2M
    case title3
    case title3_28
    case body1Sb
    case body2B
    case body2Sb
    case body2Sb20
    case body2Sb22
    case body2R22
    case body2R
    case body3B
    case body3Sb
    case body3M
    case body3R22
    case body4B
    case body4Sb
    case body4M
    case inputLabel
    case inputText1
    case cardTitle
    case breakthroughLarge
    case breakthroughSmall
    case buttonLarge
    case buttonMedium
    case buttonSmall
    case custom(weight: FontWeight, size: CGFloat, lineHeight: CGFloat)

    public var weight: FontWeight {
        switch self {
        case .header0:
            .bold
        case .header1:
            .medium
        case .title0:
            .semiBold
        case .title1:
            .semiBold
        case .title2B:
            .bold
        case .title2Sb:
            .semiBold
        case .title2M:
            .medium
        case .title3:
            .semiBold
        case .title3_28:
            .semiBold
        case .body1Sb:
            .semiBold
        case .body2B:
            .bold
        case .body2Sb:
            .semiBold
        case .body2Sb20:
            .semiBold
        case .body2Sb22:
            .semiBold
        case .body2R22:
            .regular
        case .body2R:
            .regular
        case .body3B:
            .bold
        case .body3Sb:
            .semiBold
        case .body3M:
            .medium
        case .body3R22:
            .regular
        case .body4B:
            .bold
        case .body4Sb:
            .semiBold
        case .body4M:
            .medium
        case .inputLabel:
            .semiBold
        case .inputText1:
            .regular
        case .cardTitle:
            .semiBold
        case .breakthroughLarge:
            .regular
        case .breakthroughSmall:
            .medium
        case .buttonLarge:
            .semiBold
        case .buttonMedium:
            .semiBold
        case .buttonSmall:
            .semiBold
        case let .custom(weight, _, _):
            weight
        }
    }

    public var size: CGFloat {
        switch self {
        case .header0:
            30
        case .header1:
            28
        case .title0:
            24
        case .title1:
            20
        case .title2B:
            18
        case .title2Sb:
            18.0
        case .title2M:
            18.0
        case .title3:
            16.0
        case .title3_28:
            16.0
        case .body1Sb:
            15.0
        case .body2B:
            14.0
        case .body2Sb:
            14.0
        case .body2Sb20:
            14.0
        case .body2Sb22:
            14.0
        case .body2R22:
            14.0
        case .body2R:
            14.0
        case .body3B:
            12.0
        case .body3Sb:
            12.0
        case .body3M:
            12.0
        case .body3R22:
            12.0
        case .body4B:
            10.0
        case .body4Sb:
            10.0
        case .body4M:
            10.0
        case .inputLabel:
            13.0
        case .inputText1:
            14.0
        case .cardTitle:
            13.0
        case .breakthroughLarge:
            12.0
        case .breakthroughSmall:
            10.0
        case .buttonLarge:
            16
        case .buttonMedium:
            14
        case .buttonSmall:
            12
        case let .custom(_, size, _):
            size
        }
    }

    public var lineHeight: CGFloat {
        switch self {
        case .header0:
            40
        case .header1:
            35
        case .title0:
            30
        case .title1:
            25
        case .title2B:
            23
        case .title2Sb:
            23
        case .title2M:
            23
        case .title3:
            20
        case .title3_28:
            28
        case .body1Sb:
            19
        case .body2B:
            18
        case .body2Sb:
            17
        case .body2Sb20:
            20
        case .body2Sb22:
            22
        case .body2R22:
            22
        case .body2R:
            18
        case .body3B:
            15
        case .body3Sb:
            15
        case .body3M:
            15
        case .body3R22:
            22
        case .body4B:
            13
        case .body4Sb:
            13
        case .body4M:
            13
        case .inputLabel:
            16
        case .inputText1:
            20
        case .cardTitle:
            20
        case .breakthroughLarge:
            15
        case .breakthroughSmall:
            12
        case .buttonLarge:
            20
        case .buttonMedium:
            18
        case .buttonSmall:
            16
        case let .custom(_, _, lineHeight):
            lineHeight
        }
    }
}
