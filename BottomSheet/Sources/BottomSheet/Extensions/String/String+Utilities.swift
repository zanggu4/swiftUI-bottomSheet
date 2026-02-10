//
//  String+Utilities.swift
//  Foundation
//
//  Created by 이현재 on 8/20/25.
//  Copyright © 2025 WAUG. All rights reserved.
//

import Foundation

public extension StringUtilWrapper {
    /// 이모지 포함 여부
    /// - Note: 전체 문자열을 순회하지 않고 첫 이모지를 발견하면 바로 true를 반환하여 더 효율적입니다.
    var containsEmoji: Bool {
        base.contains(where: \.isEmoji)
    }

    /// 모든 이모지를 제거한 새로운 문자열
    var removingEmojis: String {
        String(base.filter { !$0.isEmoji })
    }

    /// 비어있지 않은지 여부
    var isNotEmpty: Bool {
        !base.isEmpty
    }

    /// URL에서 쿼리 파라미터를 제거한 URL
    /// - Note: 유효하지 않은 URL 문자열일 경우 nil을 반환합니다.
    var clearedQueryURL: URL? {
        var components = URLComponents(string: base)
        components?.queryItems = nil
        return components?.url
    }

    /// 앞뒤 공백 및 개행 문자를 제거한 문자열
    var trimmed: String {
        base.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// UTF-8 인코딩 기반의 Base64 인코딩 문자열
    var base64Encoded: String? {
        base.data(using: .utf8)?.base64EncodedString()
    }

    /// 한글 초성 또는 첫 글자를 반환
    var initial: String? {
        guard let firstChar = base.first else { return nil }

        // 한글 유니코드 상수
        let hangulSyllablesStart: UInt32 = 0xAC00 // '가'
        let initialSoundOffset: UInt32 = 588 // 초성 오프셋 (21 * 28)
        let initialSoundStart: UInt32 = 0x1100 // 초성 시작

        guard let scalarValue = firstChar.unicodeScalars.first?.value else { return String(firstChar) }

        // 한글 음절 범위(가-힣)에 있는지 확인
        if (hangulSyllablesStart ... 0xD7AF).contains(scalarValue) {
            let initialIndex = (scalarValue - hangulSyllablesStart) / initialSoundOffset
            if let initialScalar = UnicodeScalar(initialSoundStart + initialIndex) {
                return String(Character(initialScalar))
            }
        }

        // 한글이 아니면 첫 글자 그대로 반환
        return String(firstChar)
    }

    /// 문자열을 Int로 변환 (실패 시 0)
    var toInt: Int {
        Int(base) ?? 0
    }

    /// 문자열을 Double로 변환 (실패 시 0.0)
    var toDouble: Double {
        Double(base) ?? 0.0
    }

    /// 문자열을 Bool로 변환 (실패 시 false)
    var toBool: Bool {
        Bool(base) ?? false
    }

    /// 백스페이스 문자(\\b)인지 확인
    var isBackspace: Bool {
        // U+0008은 백스페이스 문자의 유니코드입니다.
        base == "\u{0008}"
    }

    /// 문자열에서 숫자만 추출하여 Int로 반환
    var filteredNumber: Int {
        Int(base.filter(\.isNumber)) ?? 0
    }

    /// 글자별로 줄바꿈
    var forceCharWrapping: String {
        base.map { String($0) }.joined(separator: "\u{200B}")
    }

    /// 영문/숫자(ASCII)는 단어 단위로, 그 외 모든 문자(한글, 한자, 일본어 등)는 글자 단위로 줄바꿈을 유도하는 문자열을 반환합니다.
    /// Non-ASCII 문자가 연속될 경우, 그 사이에 줄바꿈이 가능한 'Zero-Width Space'를 삽입합니다.
    var smartLineBreak: String {
        // 문자열에 문자가 1개 이하일 경우 처리할 필요가 없음
        guard base.count > 1 else { return base }

        var result = ""
        // 문자열을 순회하며 현재 문자와 다음 문자를 비교
        for i in 0 ..< (base.count - 1) {
            let currentChar = base[base.index(base.startIndex, offsetBy: i)]
            result.append(currentChar)

            // 현재 문자와 다음 문자가 둘 다 ASCII가 아닐 경우에만
            // 사이에 Zero-Width Space를 삽입하여 줄바꿈 기회를 줌.
            let nextChar = base[base.index(base.startIndex, offsetBy: i + 1)]
            if !currentChar.isASCII, !nextChar.isASCII {
                result.append("\u{200B}")
            }
        }

        // 마지막 문자 추가
        if let lastChar = base.last {
            result.append(lastChar)
        }

        return result
    }

    /// 지정된 길이의 배열에 따라 문자열을 자릅니다.
    /// - Parameter lengths: 자를 길이의 배열 (예: [3, 4, 4])
    /// - Returns: 잘린 문자열의 배열. 문자열이 충분히 길지 않으면 nil을 반환합니다.
    func split(by lengths: [Int]) -> [String]? {
        // 총 길이가 원본 문자열보다 긴지 확인
        guard base.count >= lengths.reduce(0, +) else {
            return nil
        }

        var result = [String]()
        var currentIndex = base.startIndex

        for length in lengths {
            // 현재 위치에서 주어진 길이만큼 떨어진 곳의 인덱스를 계산
            let endIndex = base.index(currentIndex, offsetBy: length)
            // 부분 문자열을 잘라내어 배열에 추가
            result.append(String(base[currentIndex ..< endIndex]))
            // 현재 위치를 다음 시작 위치로 업데이트
            currentIndex = endIndex
        }

        return result
    }

    /// HTML 특수문자를 이스케이프하여 XSS 방지
    var htmlEscaped: String {
        base.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

private extension Character {
    /// 이모지 여부 (숫자형 이모지는 제외)
    var isEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.properties.numericType == nil
    }
}
