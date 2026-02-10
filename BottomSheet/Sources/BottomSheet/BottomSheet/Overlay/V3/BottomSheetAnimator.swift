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

    // MARK: - Init

    init(sheetView: UIView, containerView: UIView) {
        self.sheetView = sheetView
        self.containerView = containerView
    }

    // MARK: - Animations

    func animateSpringLayout(completion: (() -> Void)? = nil) {
        guard let containerView else {
            completion?()
            return
        }

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

    func animateEaseOutLayout(completion: (() -> Void)? = nil) {
        guard let containerView else {
            completion?()
            return
        }

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

    func animateSnapBack(completion: (() -> Void)? = nil) {
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

    func animateSlideOutRight(completion: (() -> Void)? = nil) {
        guard let sheetView else {
            completion?()
            return
        }

        let sheetWidth = sheetView.bounds.width

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
