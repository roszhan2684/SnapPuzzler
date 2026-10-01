//
//  HowToPlayView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("How To Play")
                    .font(ThemeFont.title(32))
                    .foregroundColor(.white)

                InstructionCard(
                    step: "1",
                    title: "Show Your Hand",
                    description: "Hold your hand in front of the camera so the app can detect your fingers."
                )

                InstructionCard(
                    step: "2",
                    title: "Pinch To Create Frame",
                    description: "Pinch with your thumb and index finger. The frame appears and follows your hand."
                )

                InstructionCard(
                    step: "3",
                    title: "Hold Steady To Snap",
                    description: "Keep the pinch stable for a moment to capture the framed part of the live camera view."
                )

                InstructionCard(
                    step: "4",
                    title: "Solve The Puzzle",
                    description: "The selected image becomes a puzzle on the same screen. Rearrange the tiles to solve it."
                )

                InstructionCard(
                    step: "5",
                    title: "Beat Your Best Time",
                    description: "Finish faster to improve your score and set new records."
                )
            }
            .padding()
        }
        .background(Theme.spaceBlack.ignoresSafeArea())
        .navigationTitle("How To Play")
        .navigationBarTitleDisplayMode(.inline)
    }
}
