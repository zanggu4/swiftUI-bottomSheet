//
//  BottomSheetGestureHandler.swift
//  BottomSheet
//
//  Created by Hyeonjae Lee on 2026.
//  Handles gesture recognition and processing for BottomSheet.
//

import UIKit

// MARK: - BottomSheetGestureHandlerDelegate

@available(iOS 15.0, *)
@MainActor
protocol BottomSheetGestureHandlerDelegate: AnyObject {
    func gestureHandlerRequestsDismiss()
    func gestureHandlerRequestsSlideOutRight()
    func gestureHandlerRequestsSnapBack()
    func gestureHandlerDidUpdateProgress(_ progress: CGFloat, animated: Bool)
}

// MARK: - BottomSheetGestureHandler

@available(iOS 15.0, *)
@MainActor
final class BottomSheetGestureHandler {
    // MARK: - Properties

    weak var delegate: BottomSheetGestureHandlerDelegate?

    private weak var containerView: UIView?
    private weak var sheetView: UIView?
    private weak var scrollView: UIScrollView?

    private let edgeSwipeBackToDismiss: Bool
    private var sheetHeight: CGFloat

    private var isDraggingSheet = false
    private var gestureStartedWithScroll = false

    /// 헤더 팬 제스처의 방향 잠금
    private enum DragAxis { case horizontal, vertical }
    private var lockedAxis: DragAxis?

    var isSheetBeingDragged: Bool { isDraggingSheet }

    // MARK: - Init

    init(
        containerView: UIView,
        sheetView: UIView,
        scrollView: UIScrollView,
        edgeSwipeBackToDismiss: Bool,
        sheetHeight: CGFloat
    ) {
        self.containerView = containerView
        self.sheetView = sheetView
        self.scrollView = scrollView
        self.edgeSwipeBackToDismiss = edgeSwipeBackToDismiss
        self.sheetHeight = sheetHeight
    }

    func updateSheetHeight(_ height: CGFloat) {
        sheetHeight = height
    }

    // MARK: - Edge Swipe Gesture

    func handleEdgeSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let containerView, let sheetView else { return }

        let location = gesture.location(in: containerView)
        let velocity = gesture.velocity(in: containerView)
        let sheetWidth = sheetView.bounds.width

        switch gesture.state {
        case .changed:
            let clampedX = max(0, location.x * SheetConstants.horizontalDragResistance)
            sheetView.transform = CGAffineTransform(translationX: clampedX, y: 0)

            guard sheetWidth > 0 else { return }
            let progress = clampedX / sheetWidth
            delegate?.gestureHandlerDidUpdateProgress(min(1, progress), animated: false)

        case .ended:
            let dragX = sheetView.transform.tx
            let shouldDismiss = dragX > SheetConstants.edgeSwipeDismissThreshold || velocity.x > SheetConstants.velocityThreshold

            if shouldDismiss {
                delegate?.gestureHandlerRequestsSlideOutRight()
            } else {
                delegate?.gestureHandlerRequestsSnapBack()
                delegate?.gestureHandlerDidUpdateProgress(0, animated: true)
            }

        case .cancelled, .failed:
            delegate?.gestureHandlerRequestsSnapBack()
            delegate?.gestureHandlerDidUpdateProgress(0, animated: true)

        default:
            break
        }
    }

    // MARK: - Scroll View Pan Gesture

    func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let containerView,
              let sheetView,
              let scrollView else { return }

        let translation = gesture.translation(in: containerView)
        let velocity = gesture.velocity(in: containerView)
        let offsetY = scrollView.contentOffset.y

        switch gesture.state {
        case .began:
            gestureStartedWithScroll = offsetY > 0

        case .changed:
            if offsetY > 0 {
                gestureStartedWithScroll = true
            }

            if offsetY <= 0, translation.y > 0, !gestureStartedWithScroll {
                isDraggingSheet = true
                sheetView.transform = CGAffineTransform(translationX: 0, y: translation.y)
                scrollView.contentOffset.y = 0

                let height = sheetHeight > 0 ? sheetHeight : SheetConstants.defaultSheetHeight
                let progress = translation.y / height
                delegate?.gestureHandlerDidUpdateProgress(min(1, progress), animated: false)
            } else if isDraggingSheet {
                let clampedY = max(0, translation.y)
                sheetView.transform = CGAffineTransform(translationX: 0, y: clampedY)
                scrollView.contentOffset.y = 0

                let height = sheetHeight > 0 ? sheetHeight : SheetConstants.defaultSheetHeight
                let progress = clampedY / height
                delegate?.gestureHandlerDidUpdateProgress(min(1, progress), animated: false)
            }

        case .ended:
            if isDraggingSheet {
                let dragY = sheetView.transform.ty
                let shouldDismiss = dragY > SheetConstants.dismissThreshold || velocity.y > SheetConstants.velocityThreshold

                if shouldDismiss {
                    delegate?.gestureHandlerRequestsDismiss()
                } else {
                    delegate?.gestureHandlerRequestsSnapBack()
                    delegate?.gestureHandlerDidUpdateProgress(0, animated: true)
                }
            }
            isDraggingSheet = false
            gestureStartedWithScroll = false

        case .cancelled, .failed:
            if isDraggingSheet {
                delegate?.gestureHandlerRequestsSnapBack()
                delegate?.gestureHandlerDidUpdateProgress(0, animated: true)
            }
            isDraggingSheet = false
            gestureStartedWithScroll = false

        default:
            break
        }
    }
}
