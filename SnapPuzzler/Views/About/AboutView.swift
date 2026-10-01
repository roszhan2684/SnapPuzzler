//
//  AboutView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("About SNAPPUZZLER")
                    .font(ThemeFont.title(32))
                    .foregroundColor(.white)

                Text("SNAPPUZZLER is a live camera puzzle game where users frame part of the real world using hand gestures, snap it, and solve it as a puzzle on the same screen.")
                    .font(ThemeFont.body(15))
                    .foregroundColor(.white.opacity(0.85))

                Text("Version 1 Features")
                    .font(ThemeFont.body(18))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("• Live camera gameplay")
                    Text("• Hand tracking overlay")
                    Text("• Pinch-based frame control")
                    Text("• Same-screen puzzle generation")
                    Text("• High scores and settings")
                }
                .font(ThemeFont.body(15))
                .foregroundColor(.white.opacity(0.8))

                Text("Permissions")
                    .font(ThemeFont.body(18))
                    .foregroundColor(.white)

                Text("The app requires camera access to detect the hand and capture the puzzle region.")
                    .font(ThemeFont.body(15))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding()
        }
        .background(Theme.spaceBlack.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
