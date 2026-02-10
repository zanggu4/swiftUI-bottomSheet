//
//  BottomSheetAnimator.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Encapsulates animation logic for BottomSheet.
//

import UIKit

// MARK: - BottomSheetAnimator

@available(iOS 15.0, *)
@MainActor
final class BottomSheetAnimator {
    // MARK: - Properties

    private weak var sheetView: UIView?
    private weak var containerView: UIView?
    private var sheetBottomConstraint: NSLayoutConstraint?

    var onDragProgressChanged: ((CGFloat, Bool) -> Void)?

    /// Called when the bottom constraint is replaced during animation.
    var onBottomConstraintChanged: ((NSLayoutConstraint) -> Void)?

    // MARK: - Init

    init(sheetView: UIView, containerView: UIView) {
        self.sheetView = sheetView
        self.containerView = containerView
    }

    // MARK: - Constraint Management

    func setBottomConstraint(_ constraint: NSLayoutConstraint?) {
        sheetBottomConstraint = constraint
    }

    // MARK: - Animations

    func showAnimation(completion: (() -> Void)? = nil) {
        guard let sheetView, let containerView else { return }

        containerView.layoutIfNeeded()

        sheetBottomConstraint?.isActive = false
        let newConstraint = sheetView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        newConstraint.isActive = true
        sheetBottomConstraint = newConstraint
        onBottomConstraintChanged?(newConstraint)

        onDragProgressChanged?(0, false)

        UIView.animate(
            withDuration: SheetConstants.showAnimationDuration,
            delay: 0,
            usingSpringWithDamping: SheetConstants.springDamping,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
        ) {
            containerView.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }

    func hideAnimation(completion: (() -> Void)? = nil) {
        guard let sheetView, let containerView else {
            completion?()
            return
        }

        sheetBottomConstraint?.isActive = false
        let newConstraint = sheetView.topAnchor.constraint(equalTo: containerView.bottomAnchor)
        newConstraint.isActive = true
        sheetBottomConstraint = newConstraint
        onBottomConstraintChanged?(newConstraint)

        onDragProgressChanged?(1, true)

        UIView.animate(
            withDuration: SheetConstants.hideAnimationDuration,
            delay: 0,
            options: [.curveEaseOut],
        ) {
            containerView.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }

    func snapBackAnimation(completion: (() -> Void)? = nil) {
        guard let sheetView, let containerView else {
            completion?()
            return
        }

        UIView.animate(
            withDuration: SheetConstants.snapBackAnimationDuration,
            delay: 0,
            usingSpringWithDamping: SheetConstants.springDamping,
            initialSpringVelocity: 0,
            options: [],
        ) {
            sheetView.transform = .identity
            containerView.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }

    func slideOutRightAnimation(completion: (() -> Void)? = nil) {
        guard let sheetView else {
            completion?()
            return
        }

        let sheetWidth = sheetView.bounds.width
        onDragProgressChanged?(1, true)

        UIView.animate(
            withDuration: SheetConstants.hideAnimationDuration,
            delay: 0,
            options: [.curveEaseOut],
        ) {
            sheetView.transform = CGAffineTransform(translationX: sheetWidth, y: 0)
        } completion: { _ in
            completion?()
        }
    }
}
