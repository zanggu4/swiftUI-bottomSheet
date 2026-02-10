//
//  Date+Utilities.swift
//  Foundation
//
//  Created by 이현재 on 9/19/25.
//

import Foundation

public extension Date {
    var util: DateUtilWrapper { DateUtilWrapper(self) }
}

public struct DateUtilWrapper {
    let base: Date
    fileprivate init(_ base: Date) { self.base = base }
}

public extension DateUtilWrapper {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(base, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(base, inSameDayAs: date) }

    var isInThisYear: Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek: Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(base) }
    var isInToday: Bool { Calendar.current.isDateInToday(base) }
    var isInTomorrow: Bool { Calendar.current.isDateInTomorrow(base) }

    var isInTheFuture: Bool { base > Date() }
    var isInThePast: Bool { base < Date() }

    /// 두 Date의 차이 계산을 분 단위로 반환
    /// 1시간 30분 차이라면 90 반환, since가 nil이면 0 반환
    func minuteDiffs(since: Date?) -> Int {
        guard let since else { return 0 }
        let interval = base.timeIntervalSince(since)
        return Int(interval / 60.0)
    }

    // 시간 설정
    func set(hour: Int, minute: Int, second: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: hour, minute: minute, second: second, of: base)!
    }

    /// 만나이
    var westernAge: Int {
        let calendar = Calendar.current
        let targetYear = calendar.component(.year, from: base)
        let today = Date()
        let yearFromToday = calendar.component(.year, from: today)
        var age = yearFromToday - targetYear

        // 년도를 오늘과 같은 년으로 설정
        // 날짜가 지났는지 안지났는지 체크
        var dateComponents = DateComponents()
        dateComponents.year = yearFromToday
        dateComponents.month = calendar.component(.month, from: base)
        dateComponents.day = calendar.component(.day, from: base)
        let sameYear = calendar.date(from: dateComponents)!

        // 오늘이 생일보다 이전인 경우 1을 빼준다.
        if today < sameYear {
            age = age - 1
        }
        return age
    }

    func get(_ component: Calendar.Component) -> Int {
        let calendar = Calendar.current
        return calendar.component(component, from: base)
    }

    var year: Int {
        let year = get(.year)
        return year
    }

    var month: Int {
        let month = get(.month)
        return month
    }

    var isSunday: Bool {
        let dateComponents = Calendar.current.dateComponents([.weekday], from: base)
        return dateComponents.weekday == 1
    }

    var isSaturday: Bool {
        let dateComponents = Calendar.current.dateComponents([.weekday], from: base)
        return dateComponents.weekday == 7
    }

    func set(year: Int? = nil, month: Int? = nil, day: Int? = nil) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: base)
        if let year { components.year = year }
        if let month { components.month = month }
        if let day { components.day = day }
        return calendar.date(from: components)
    }
}
