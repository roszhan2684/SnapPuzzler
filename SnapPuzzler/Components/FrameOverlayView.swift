//
//  FrameOverlayView.swift
//  SnapPuzzler
//

import SwiftUI

struct FrameOverlayView: View {
    let frameRect: FrameRect
    let gridSize: Int

    var body: some View {
        GeometryReader { geometry in
            if frameRect.isVisible {
                let width = frameRect.size.width * geometry.size.width
                let height = frameRect.size.height * geometry.size.height
                let centerX = frameRect.center.x * geometry.size.width
                let centerY = frameRect.center.y * geometry.size.height

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Theme.neonCoral, lineWidth: 3)
                        .frame(width: width, height: height)

                    gridLines(width: width, height: height)
                        .frame(width: width, height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .position(x: centerX, y: centerY)
                .shadow(color: Theme.neonCoral.opacity(0.25), radius: 10)
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func gridLines(width: CGFloat, height: CGFloat) -> some View {
        Canvas { context, size in
            guard gridSize > 1 else { return }

            var path = Path()

            let cellWidth = width / CGFloat(gridSize)
            let cellHeight = height / CGFloat(gridSize)

            for i in 1..<gridSize {
                let x = CGFloat(i) * cellWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: height))
            }

            for i in 1..<gridSize {
                let y = CGFloat(i) * cellHeight
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }

            context.stroke(
                path,
                with: .color(Theme.neonCoral.opacity(0.7)),
                lineWidth: 1.5
            )
        }
    }
}
