//
//  String+UtilWrapper.swift
//  Foundation
//
//  Created by 이현재 on 8/28/25.
//

public extension String {
    var util: StringUtilWrapper { StringUtilWrapper(self) }
}

public struct StringUtilWrapper {
    public let base: String
    fileprivate init(_ base: String) { self.base = base }
}
