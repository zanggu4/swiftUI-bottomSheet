//
//  Array+Utilities.swift
//  waug
//
//  Created by 이현재 on 2020/03/18.
//  Copyright © 2020 WAUG. All rights reserved.
//

import Foundation

public extension Array {
    var util: ArrayUtilWrapper<Element> { ArrayUtilWrapper(self) }
}

public struct ArrayUtilWrapper<Element> {
    let base: [Element]

    fileprivate init(_ base: [Element]) {
        self.base = base
    }
}

public extension ArrayUtilWrapper {
    var isNotEmpty: Bool {
        !base.isEmpty
    }

    /// 안전하게 인덱스의 값을 가져온다.
    subscript(safe index: Int) -> Element? {
        base.indices ~= index ? base[index] : nil
    }

    /// 안전하게 범위내의 값을 가져온다.
    subscript(safe range: Range<Int>) -> [Element] {
        // range에 포함된 index의 값만 반환
        base.enumerated().compactMap { index, value -> Element? in
            range ~= index ? value : nil
        }
    }

    func sumOf(_ selector: (Element) -> Int) -> Int {
        base.reduce(0) { partialResult, element in
            partialResult + selector(element)
        }
    }

    func sumOf(_ selector: (Element) -> Double) -> Double {
        base.reduce(0.0) { partialResult, element in
            partialResult + selector(element)
        }
    }

    /// 배열을 사이즈에 맞게 서브 배열로 만든다.
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: base.count, by: size).map {
            Array(base[$0 ..< Swift.min($0 + size, base.count)])
        }
    }
}

public extension ArrayUtilWrapper where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        for item in base {
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

public extension ArrayUtilWrapper where Element: Numeric {
    func joined(separator: String = "") -> String {
        base.map { "\($0)" }.joined(separator: separator)
    }

    func sum() -> Element {
        base.reduce(.zero) { partialResult, value in
            partialResult + value
        }
    }
}
