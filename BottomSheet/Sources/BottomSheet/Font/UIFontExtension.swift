//
//  UIFontExtension.swift
//  DesignSystem
//
//  Created by 이현재 on 2025/08/20.
//  Copyright © 2025 WAUG. All rights reserved.
//

import UIKit

/// 커스텀 폰트 등록
/// FontStyle 사용시 호출해줘야 에러가 안남
/// 데모나 프리뷰에서 사용하기
public func registerCustomFonts() {
    let bundle = Bundle.module
    let urls = bundle.urls(forResourcesWithExtension: "otf", subdirectory: nil)
    urls?.forEach { url in
        UIFont.registerFont(from: url)
    }
}

private extension UIFont {
    /// 폰트 등록
    /// https://forums.developer.apple.com/forums/thread/652636 참고
    static func registerFont(from url: URL) {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else { return }
        guard let font = CGFont(fontDataProvider) else { return }
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font, &error) else { return }
    }
}
