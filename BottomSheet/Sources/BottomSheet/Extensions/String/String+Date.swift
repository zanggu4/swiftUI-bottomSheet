//
//  String+Date.swift
//  Foundation
//
//  Created by 이현재 on 9/19/25.
//

import Foundation

public extension StringUtilWrapper {
    /// String -> Date? 로 리턴합니다. format이 없다면
    /// yyyy-MM-dd / yyyy-MM-dd'T'HH:mm:ss / yyyy-MM-dd HH:mm:ss 포맷 으로 파싱을 시도합니다.
    /// - Parameters:
    ///     - format: String을 Date로 parsing 할 포맷 / 기본값 nil
    func toDate(format: String? = nil) -> Date? {
        let formatter = DateFormatter()
        if let format {
            let language = "ko_KR"
            let localeId = String(language.prefix(2))
            formatter.locale = Locale(identifier: localeId)
            formatter.dateFormat = format
            return formatter.date(from: base)
        } else {
            let formats = [
                "yyyy-MM-dd",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm",
            ]

            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: base) {
                    return date
                }
            }
            return nil
        }
    }
}

public extension DateUtilWrapper {
    /// Date를 입력한 포맷에 맞는 String으로 리턴합니다.
    /// format이 nil이면 yyyy-MM-dd 포맷으로 리턴합니다.
    /// - Parameters:
    ///     - format: Date를 어떤 String 으로 변환할건지 / 기본값 nil
    func toString(format: String? = nil) -> String {
        let formatter = DateFormatter()
        let language = "ko_KR"
        let localeId = String(language.prefix(2))
        formatter.locale = Locale(identifier: localeId)
        if let format {
            formatter.dateFormat = format
        } else {
            formatter.dateFormat = "yyyy-MM-dd"
        }
        return formatter.string(from: base)
    }

    /// 영어일때 "MMM dd, yyyy",
    /// 영어가 아닐땐 "yyyy-MM-dd"포맷으로 리턴
    func toLocalizedString() -> String {
        let formatter = DateFormatter()
        let language = "ko_KR"
        let localeId = String(language.prefix(2))

        if localeId.uppercased() == "EN" {
            formatter.dateFormat = "MMM dd, yyyy"
        } else {
            formatter.dateFormat = "yyyy-MM-dd"
        }
        return formatter.string(from: base)
    }

    /// 0시 0분
    var midnight: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: base)
    }

    /// 내일
    var tomorrow: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: base)!
    }
}
