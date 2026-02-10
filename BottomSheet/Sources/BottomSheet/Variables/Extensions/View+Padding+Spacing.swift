//
//  View+Padding+Spacing.swift
//  DesignSystem
//
//  Created by 이현재 on 1/2/26.
//

import SwiftUI

public extension View {
    // MARK: - SpacingToken (Default)

    /// 디자인 시스템 SpacingToken을 사용하여 패딩을 적용합니다.
    func padding(_ token: SpacingToken) -> some View {
        padding(.all, token.value)
    }

    /// 특정 방향에 디자인 시스템 SpacingToken을 사용하여 패딩을 적용합니다.
    func padding(_ edges: Edge.Set, _ token: SpacingToken) -> some View {
        padding(edges, token.value)
    }

    // MARK: - SpacingToken.Padding (Semantic)

    /// 디자인 시스템 Semantic Padding을 사용하여 패딩을 적용합니다.
    func padding(_ token: SpacingToken.Padding) -> some View {
        padding(.all, token.value)
    }

    /// 특정 방향에 디자인 시스템 Semantic Padding을 사용하여 패딩을 적용합니다.
    func padding(_ edges: Edge.Set, _ token: SpacingToken.Padding) -> some View {
        padding(edges, token.value)
    }

    // MARK: - SpacingToken.SpacingX

    /// 디자인 시스템 SpacingX를 사용하여 패딩을 적용합니다.
    func padding(_ token: SpacingToken.SpacingX) -> some View {
        padding(.all, token.value)
    }

    /// 특정 방향에 디자인 시스템 SpacingX를 사용하여 패딩을 적용합니다.
    func padding(_ edges: Edge.Set, _ token: SpacingToken.SpacingX) -> some View {
        padding(edges, token.value)
    }

    // MARK: - SpacingToken.SpacingY

    /// 디자인 시스템 SpacingY를 사용하여 패딩을 적용합니다.
    func padding(_ token: SpacingToken.SpacingY) -> some View {
        padding(.all, token.value)
    }

    /// 특정 방향에 디자인 시스템 SpacingY를 사용하여 패딩을 적용합니다.
    func padding(_ edges: Edge.Set, _ token: SpacingToken.SpacingY) -> some View {
        padding(edges, token.value)
    }
}
