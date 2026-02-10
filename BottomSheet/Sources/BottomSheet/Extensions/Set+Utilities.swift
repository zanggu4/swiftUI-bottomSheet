//
//  Set+Utilities.swift
//  Foundation
//
//  Created by 이현재 on 9/19/25.
//

import Foundation

public extension Collection {
    var util: CollectionUtilWrapper<Element> { CollectionUtilWrapper(self) }
}

public struct CollectionUtilWrapper<Element> {
    let base: any Collection<Element>

    fileprivate init(_ base: any Collection<Element>) {
        self.base = base
    }
}

public extension CollectionUtilWrapper {
    var isNotEmpty: Bool {
        !base.isEmpty
    }

    // 컬렉션 요소를 변환하고 Set으로 반환하는 헬퍼
    func mapToSet<T: Hashable>(_ transform: (Element) throws -> T) rethrows -> Set<T> {
        var resultSet = Set<T>()
        resultSet.reserveCapacity(base.count)
        for element in base {
            try resultSet.insert(transform(element))
        }
        return resultSet
    }
}
