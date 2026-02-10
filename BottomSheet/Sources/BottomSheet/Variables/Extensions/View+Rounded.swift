//
//  View+Rounded.swift
//  DesignSystem
//
//  Created by 이현재 on 1/2/26.
//

import SwiftUI

// MARK: - Rounded View Extensions

public extension View {
    /// 디자인 시스템에 정의된 CornerRadius를 적용합니다.
    /// 배경색(fill)과 테두리(border)를 선택적으로 함께 적용할 수 있습니다.
    ///
    /// - Parameters:
    ///   - radius: RadiusToken (.xxs, .xs, .s, .m, .l, .xl, .xxl, .full)
    ///   - fill: 배경 색상 (기본값: nil)
    ///   - border: 테두리 색상 (기본값: nil)
    ///   - width: 테두리 두께 (기본값: 1)
    /// - Returns: 스타일이 적용된 View
    ///
    /// Usage:
    /// ```swift
    /// // 1. Radius만
    /// View().rounded(.m)
    ///
    /// // 2. Radius + 배경
    /// View().rounded(.m, fill: .pink)
    ///
    /// // 3. Radius + 테두리
    /// View().rounded(.m, border: .gray)
    ///
    /// // 4. Radius + 배경 + 테두리
    /// View().rounded(.m, fill: .white, border: .gray)
    /// ```
    @ViewBuilder
    func rounded(
        _ radius: RadiusToken,
        fill: Color? = nil,
        border: Color? = nil,
        width: CGFloat = 1,
    ) -> some View {
        if radius == .full {
            background {
                if let fill {
                    Capsule().fill(fill)
                }
            }
            .clipShape(Capsule())
            .overlay {
                if let border {
                    Capsule().stroke(border, lineWidth: width)
                }
            }
        } else {
            let shape = RoundedRectangle(cornerRadius: radius.value)
            background {
                if let fill {
                    shape.fill(fill)
                }
            }
            .clipShape(shape)
            .overlay {
                if let border {
                    shape.stroke(border, lineWidth: width)
                }
            }
        }
    }
}
