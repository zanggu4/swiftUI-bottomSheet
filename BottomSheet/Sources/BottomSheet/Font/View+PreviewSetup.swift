//
//  View+PreviewSetup.swift
//  DesignSystem
//
//  Created by 이현재 on 2025/08/20.
//  Copyright © 2025 WAUG. All rights reserved.
//

import SwiftUI

public extension View {
    /// SwiftUI 프리뷰를 위한 초기화 작업을 수행합니다.
    /// (예: 커스텀 폰트 등록)
    func previewSetup(language: String? = nil) -> some View {
        modifier(PreviewInitializerModifier(language: language))
    }
}

private struct PreviewInitializerModifier: ViewModifier {
    // Modifier가 생성될 때 폰트 등록 로직을 호출합니다.
    init(language: String?) {
        registerCustomFonts()
    }

    func body(content: Content) -> some View {
        content
    }
}
