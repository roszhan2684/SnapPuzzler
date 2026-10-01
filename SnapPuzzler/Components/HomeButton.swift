//
//  HomeButton.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import SwiftUI

struct HomeButton: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)

            Text(title)
                .font(ThemeFont.body(18))
        }
        .foregroundColor(Theme.spaceBlack)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.neonCoral)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.neonCoral.opacity(0.8), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
