//
//  String+Josa.swift
//  Foundation
//
//  Created by 이현재 on 8/20/25.
//  Copyright © 2025 WAUG. All rights reserved.
//

import Foundation

public extension StringUtilWrapper {
    /// 한국어 조사를 자연스럽게 변환합니다.
    ///
    /// "친구(은)는" -> "친구는"
    /// "사과(을)를" -> "사과를"
    /// "사람(이)가" -> "사람이"
    /// "그(와)과" -> "그와"
    /// "방법(으)로" -> "방법으로"
    /// "서울(으)로" -> "서울로" (ㄹ 받침 처리)
    ///
    /// - Note: `(으)로`는 `으로(로)`로 먼저 변환된 후 처리됩니다.
    var natural: String {
        // "(으)로"와 같은 축약형을 일반적인 형태로 변환
        var newString = base.replacingOccurrences(of: "(으)로", with: "으로(로)")

        let josaPatterns = [
            ("을", "를"),
            ("이", "가"),
            ("은", "는"),
            ("과", "와"),
            ("으로", "로"),
        ]

        for (josaWithBatchim, josaWithoutBatchim) in josaPatterns {
            let pattern = "\(josaWithBatchim)(\(josaWithoutBatchim))"

            // 문자열 내에서 패턴이 더 이상 없을 때까지 반복
            while let range = newString.range(of: pattern) {
                // 패턴 바로 앞의 글자를 확인
                guard let lastCharIndex = newString.index(range.lowerBound, offsetBy: -1, limitedBy: newString.startIndex) else {
                    // 문자열 맨 앞에 패턴이 있으면 받침이 없는 것으로 간주
                    newString.replaceSubrange(range, with: josaWithoutBatchim)
                    continue
                }

                let lastChar = newString[lastCharIndex]

                // 받침이 있는 경우
                if lastChar.hasJongseong {
                    // '으로/로'의 경우, 앞 글자 받침이 'ㄹ'이면 '로'를 사용
                    if josaWithBatchim == "으로", lastChar.isRieulBatchim {
                        newString.replaceSubrange(range, with: josaWithoutBatchim)
                    } else {
                        newString.replaceSubrange(range, with: josaWithBatchim)
                    }
                } else { // 받침이 없는 경우
                    newString.replaceSubrange(range, with: josaWithoutBatchim)
                }
            }
        }
        return newString
    }
}

private extension Character {
    /// 한글 음절(가-힣)인지 확인
    private var isHangulSyllable: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return (0xAC00 ... 0xD7A3).contains(scalar.value)
    }

    /// 받침(종성)이 있는지 여부
    var hasJongseong: Bool {
        guard isHangulSyllable, let scalarValue = unicodeScalars.first?.value else {
            return false
        }
        // 한글 음절의 마지막 유니코드 값(0xAC00)을 빼고 28로 나눈 나머지가 0이 아니면 받침이 있음
        return (scalarValue - 0xAC00) % 28 != 0
    }

    /// 받침(종성)이 'ㄹ'인지 여부
    var isRieulBatchim: Bool {
        guard isHangulSyllable, let scalarValue = unicodeScalars.first?.value else {
            return false
        }
        let jongseongIndex = (scalarValue - 0xAC00) % 28
        // 'ㄹ'에 해당하는 종성 인덱스는 8입니다. (종성 시작 유니코드 0x11A8 기준)
        return jongseongIndex == 8
    }
}
