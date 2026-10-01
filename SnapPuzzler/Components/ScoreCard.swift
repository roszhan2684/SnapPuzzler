//
//  ScoreCard.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import SwiftUI

struct ScoreCard: View {
    let size: String
    let time: String
    let moves: String?

    init(size: String, time: String, moves: String? = nil) {
        self.size = size
        self.time = time
        self.moves = moves
    }

    var body: some View {
        HStack {
            Text(size)
                .font(ThemeFont.body(18))
                .foregroundColor(.white)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(time)
                    .font(ThemeFont.body(16))
                    .foregroundColor(.white.opacity(0.8))

                if let moves {
                    Text("Moves: \(moves)")
                        .font(ThemeFont.body(13))
                        .foregroundColor(.white.opacity(0.65))
                }
            }
        }
        .padding()
        .background(Theme.spaceBlack.opacity(0.65))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.neonCoral.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
