//
//  HandOverlayView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 15/03/26.
//

import SwiftUI

struct HandOverlayView: View {
    let points: [HandPoint]
    let connections: [HandConnection]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(connections) { connection in
                    Path { path in
                        let from = CGPoint(
                            x: connection.from.point.x * geometry.size.width,
                            y: connection.from.point.y * geometry.size.height
                        )
                        let to = CGPoint(
                            x: connection.to.point.x * geometry.size.width,
                            y: connection.to.point.y * geometry.size.height
                        )

                        path.move(to: from)
                        path.addLine(to: to)
                    }
                    .stroke(Theme.neonCoral.opacity(0.9), lineWidth: 2.5)
                }

                ForEach(points) { point in
                    Circle()
                        .fill(color(for: point.name))
                        .frame(width: size(for: point.name), height: size(for: point.name))
                        .overlay(
                            Circle()
                                .stroke(Theme.spaceBlack.opacity(0.35), lineWidth: 1)
                        )
                        .position(
                            x: point.point.x * geometry.size.width,
                            y: point.point.y * geometry.size.height
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func color(for name: String) -> Color {
        if fingertipNames.contains(name) {
            return Theme.neonCoral
        }
        if name == "wrist" {
            return Theme.neonCoral.opacity(0.7)
        }
        return .white
    }

    private func size(for name: String) -> CGFloat {
        if fingertipNames.contains(name) {
            return 14
        }
        if name == "wrist" {
            return 12
        }
        return 9
    }

    private var fingertipNames: Set<String> {
        ["thumbTip", "indexTip", "middleTip", "ringTip", "littleTip"]
    }
}
