//
//  Stack+SpacingToken.swift
//  DesignSystem
//
//  Created by 이현재 on 1/26/26.
//

import SwiftUI

public extension VStack {
    init(
        alignment: HorizontalAlignment = .center,
        spacing: SpacingToken,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: spacing.value, content: content)
    }
}

public extension HStack {
    init(
        alignment: VerticalAlignment = .center,
        spacing: SpacingToken,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: spacing.value, content: content)
    }
}
