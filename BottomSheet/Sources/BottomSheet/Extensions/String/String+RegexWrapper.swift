//
//  String+RegexWrapper.swift
//  Foundation
//
//  Created by 이현재 on 10/16/25.
//

import Foundation

public extension String {
    var regex: Regex {
        Regex(self)
    }
}

public struct Regex {
    private let text: String
    fileprivate init(_ text: String) {
        self.text = text
    }

    // MARK: - 유효성 검사

    public func checkPattern(pattern: RegexPattern) -> Bool {
        checkPattern(pattern: pattern.rawValue)
    }

    public func checkPattern(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return true }
        if let _ = regex.firstMatch(in: text, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: text.count)) {
            return true
        }
        return false
    }

    // MARK: - 텍스트 추출

    /// 영어만 추출
    public func extractAlphabetic() -> String {
        extract(pattern: #"[^a-zA-Z]"#)
    }

    /// 숫자만 추출
    public func extractNumeric() -> String {
        extract(pattern: #"[^0-9]"#)
    }

    /// 영어 숫자만 추출
    public func extractAlphanumeric() -> String {
        extract(pattern: #"[^a-zA-Z0-9]"#)
    }

    /// 정규식에 해당하는 텍스트만 추출
    public func extract(pattern: String) -> String {
        text.replacingOccurrences(
            of: pattern,
            with: "",
            options: .regularExpression,
        )
    }

    /// 정규식 패턴과 매칭되는 첫 번째 결과의 캡처 그룹들을 반환합니다.
    /// - Parameter regex: 정규식 패턴 문자열
    /// - Returns: 캡처된 문자열들의 배열. 매칭되지 않으면 `nil`을 반환합니다.
    public func capturedGroups(withRegex regex: String) -> [String]? {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            // self는 String 인스턴스 자신을 의미
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            guard let match = results.first else { return nil }

            // 첫 번째 캡처 그룹부터 마지막까지 추출 (전체 매치인 0번 그룹 제외)
            return (1 ..< match.numberOfRanges).map {
                let rangeBounds = match.range(at: $0)
                guard let range = Range(rangeBounds, in: text) else {
                    return ""
                }
                return String(text[range])
            }
        } catch {
            return nil
        }
    }
}
