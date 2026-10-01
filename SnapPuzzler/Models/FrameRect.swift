//
//  FrameRect.swift
//  SnapPuzzler
//

import Foundation
import CoreGraphics

struct FrameRect {
    var center: CGPoint
    var size: CGSize
    var isVisible: Bool

    static let hidden = FrameRect(
        center: .zero,
        size: .zero,
        isVisible: false
    )

    static func squareFromPoints(_ start: CGPoint, _ end: CGPoint) -> FrameRect {
        let dx = end.x - start.x
        let dy = end.y - start.y

        let side = max(abs(dx), abs(dy))

        let finalX = start.x + (dx >= 0 ? side : -side)
        let finalY = start.y + (dy >= 0 ? side : -side)

        let minX = min(start.x, finalX)
        let maxX = max(start.x, finalX)
        let minY = min(start.y, finalY)
        let maxY = max(start.y, finalY)

        return FrameRect(
            center: CGPoint(
                x: (minX + maxX) / 2,
                y: (minY + maxY) / 2
            ),
            size: CGSize(
                width: maxX - minX,
                height: maxY - minY
            ),
            isVisible: true
        )
    }
}
