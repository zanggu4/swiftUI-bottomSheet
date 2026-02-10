//
//  String+Formatting.swift
//  Foundation
//
//  Created by 이현재 on 8/20/25.
//  Copyright © 2025 WAUG. All rights reserved.
//

import Foundation

public extension StringUtilWrapper {
    /// Swift 스타일 포맷 지정자(%s)를 Objective-C 스타일(%@)로 변환합니다.
    /// e.g., "%s -> %@", "%1$s -> %1$@"
    var replacingSwiftFormatString: String {
        base.replacingOccurrences(of: #"%([0-9]+\$)?s"#, with: "%$1@", options: .regularExpression)
    }

    /// 전화번호 형식의 문자열에 하이픈(-)을 추가합니다.
    var withTelHyphen: String {
        let digits = base.filter(\.isNumber) // 숫자만 필터링하여 사용

        // 정규식을 적용하는 헬퍼 함수
        func applyRegex(pattern: String, template: String) -> String? {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(digits.startIndex..., in: digits)
                if regex.firstMatch(in: digits, options: [], range: range) != nil {
                    return regex.stringByReplacingMatches(in: digits, options: [], range: range, withTemplate: template)
                }
            } catch {
                // 정규식 에러 처리 (필요 시)
                print("Regex Error: \(error)")
            }
            return nil
        }

        // 1. 지역번호 02 (2자리)
        if digits.hasPrefix("02") {
            // 02-xxx-xxxx or 02-xxxx-xxxx
            let pattern = #"^(\d{2})(\d{3,4})(\d{4})$"#
            if let formatted = applyRegex(pattern: pattern, template: "$1-$2-$3") {
                return formatted
            }
        }

        // 2. 15xx, 16xx, 18xx 등 대표번호 (8자리)
        if digits.count == 8, ["15", "16", "18"].contains(where: digits.hasPrefix) {
            let pattern = #"^(\d{4})(\d{4})$"#
            if let formatted = applyRegex(pattern: pattern, template: "$1-$2") {
                return formatted
            }
        }

        // 3. 휴대폰 번호 및 기타 지역번호 (10-11자리)
        let pattern = #"^(\d{3})(\d{3,4})(\d{4})$"#
        if let formatted = applyRegex(pattern: pattern, template: "$1-$2-$3") {
            return formatted
        }

        // 위 형식에 맞지 않으면 원본 숫자 문자열 반환
        return digits
    }
}
