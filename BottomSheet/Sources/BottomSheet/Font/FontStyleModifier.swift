//
//  FontStyleModifier.swift
//  DesignSystem
//
//  Created by 이현재 on 2025/08/20.
//  Copyright © 2025 WAUG. All rights reserved.
//

import SwiftUI

public struct FontStyleModifier: ViewModifier {
    private let weight: FontWeight
    private let size: CGFloat
    private let lineHeight: CGFloat?
    private let baseLineHeight: CGFloat?

    public init(weight: FontWeight, size: CGFloat, lineHeight: CGFloat? = nil, baseLineHeight: CGFloat? = nil) {
        self.weight = weight
        self.size = size
        self.lineHeight = lineHeight
        self.baseLineHeight = baseLineHeight
    }

    public init(style: FontStyle) {
        weight = style.weight
        size = style.size
        lineHeight = style.lineHeight
        baseLineHeight = UIFont(style: style).lineHeight
    }

    public func body(content: Content) -> some View {
        if let lineHeight, let baseLineHeight {
            content.font(.custom(weight.rawValue, size: size))
                .lineSpacing(lineHeight - baseLineHeight)
                .padding(.vertical, (lineHeight - baseLineHeight) / 2)
        } else {
            content.font(.custom(weight.rawValue, size: size))
        }
    }
}

public extension View {
    @MainActor
    func setFont(_ fontStyle: FontStyle) -> ModifiedContent<Self, FontStyleModifier> {
        modifier(FontStyleModifier(style: fontStyle))
    }
}

private extension UIFont {
    convenience init(weight: FontWeight, size: CGFloat) {
        self.init(name: weight.rawValue, size: size)!
    }

    convenience init(style: FontStyle) {
        self.init(weight: style.weight, size: style.size)
    }
}
