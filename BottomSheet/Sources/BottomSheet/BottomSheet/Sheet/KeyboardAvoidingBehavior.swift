//
//  KeyboardAvoidingBehavior.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Shared keyboard handling behavior for BottomSheet components.
//

import UIKit

// MARK: - KeyboardAvoidingBehavior

/// Shared keyboard handling behavior that notifies via callback when keyboard appears/disappears.
@available(iOS 15.0, *)
@MainActor
final class KeyboardAvoidingBehavior {
    // MARK: - Properties

    var onKeyboardChange: ((CGFloat, TimeInterval, UIView.AnimationOptions) -> Void)?
    private(set) var currentKeyboardHeight: CGFloat = 0
    private weak var view: UIView?

    // MARK: - Init

    init() {}

    // MARK: - Public Methods

    /// Starts observing keyboard notifications.
    func startObserving(in view: UIView) {
        self.view = view

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil,
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil,
        )
    }

    /// Stops observing keyboard notifications.
    nonisolated func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Methods

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        let safeBottom = view?.safeAreaInsets.bottom ?? 0
        let adjustedHeight = max(0, keyboardFrame.height - safeBottom)
        currentKeyboardHeight = adjustedHeight

        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        onKeyboardChange?(adjustedHeight, duration, UIView.AnimationOptions(rawValue: curve << 16))
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        currentKeyboardHeight = 0

        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        onKeyboardChange?(0, duration, UIView.AnimationOptions(rawValue: curve << 16))
    }
}
