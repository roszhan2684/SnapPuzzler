//
//  InstructionCard.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import SwiftUI

struct InstructionCard: View {
    let step: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(step)
                .font(ThemeFont.body(16).bold())
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Theme.neonCoral)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(ThemeFont.body(18))
                    .foregroundColor(.white)

                Text(description)
                    .font(ThemeFont.body(14))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.spaceBlack.opacity(0.65))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.neonCoral.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
