//
//  ShareSheet.swift
//  DesignSystem
//
//  Created by 이현재 on 11/18/25.
//

import SwiftUI
import UIKit

public extension View {
    func shareSheet(
        isPresented: Binding<Bool>,
        url: String?,
    ) -> some View {
        sheet(isPresented: isPresented) {
            if #available(iOS 16.0, *) {
                ShareSheet(items: [url].compactMap(\.self))
                    .presentationDetents([.medium])
            } else {
                ShareSheet(items: [url].compactMap(\.self))
            }
        }
    }
}

/// 공유하기 팝업
/// View.sheet를 사용하여 표시
public struct ShareSheet: UIViewControllerRepresentable {
    private let items: [Any] // 공유할 항목들

    public init(items: [Any]) {
        self.items = items
    }

    public func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    public func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
