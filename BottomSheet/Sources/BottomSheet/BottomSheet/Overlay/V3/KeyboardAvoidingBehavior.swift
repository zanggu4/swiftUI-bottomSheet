//
//  KeyboardAvoidingBehavior.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Shared keyboard handling behavior for BottomSheet components.
//

import UIKit

// MARK: - KeyboardAvoidingBehavior

/// Shared keyboard handling behavior that adjusts a constraint when keyboard appears/disappears.
@available(iOS 15.0, *)
@MainActor
final class KeyboardAvoidingBehavior {
    // MARK: - Properties

    private weak var view: UIView?
    private weak var bottomConstraint: NSLayoutConstraint?

    /// The current keyboard-induced offset (0 when keyboard is hidden).
    /// Controller uses this to restore keyboard offset after constraint replacement.
    private(set) var currentKeyboardHeight: CGFloat = 0

    // MARK: - Init

    init() {}

    // MARK: - Public Methods

    /// Starts observing keyboard notifications and adjusts the given constraint.
    func startObserving(bottomConstraint: NSLayoutConstraint, view: UIView) {
        self.bottomConstraint = bottomConstraint
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

    /// Updates the bottom constraint reference (e.g. after animation replaces constraint).
    func updateConstraint(_ constraint: NSLayoutConstraint) {
        bottomConstraint = constraint
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
        bottomConstraint?.constant = -adjustedHeight

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16)) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        currentKeyboardHeight = 0

        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        bottomConstraint?.constant = 0

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16)) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }
}
