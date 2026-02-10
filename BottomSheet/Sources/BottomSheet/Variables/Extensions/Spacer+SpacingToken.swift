//
//  Spacer+SpacingToken.swift
//  DesignSystem
//
//  Created by 이현재 on 1/13/26.
//

import SwiftUI

public extension Spacer {
    func token(_ token: SpacingToken) -> some View {
        Spacer().frame(width: token.value, height: token.value)
    }
}
