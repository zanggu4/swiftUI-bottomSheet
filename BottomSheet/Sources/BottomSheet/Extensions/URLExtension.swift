//
//  URLExtension.swift
//  Utilities
//
//  Created by 이현재 on 8/20/25.
//  Copyright © 2025 WAUG. All rights reserved.
//

import Foundation

public extension URL {
    var util: URLUtilWrapper { URLUtilWrapper(self) }
}

public struct URLUtilWrapper {
    public let base: URL

    fileprivate init(_ base: URL) {
        self.base = base
    }
}

public extension URLUtilWrapper {
    /// 와그 도메인 여부
    var isWaugDomain: Bool {
        (base.scheme == "http" || base.scheme == "https") && base.host?.hasSuffix(".waug.com") ?? false
    }

    /// 호스트와 패스 부분을 가져온다
    var hostAndPath: String {
        (base.host ?? "") + base.path
    }

    var queryParameters: [String: String] {
        guard
            let components = URLComponents(url: base, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return [:] }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value?.removingPercentEncoding ?? ""
        }
    }
}
