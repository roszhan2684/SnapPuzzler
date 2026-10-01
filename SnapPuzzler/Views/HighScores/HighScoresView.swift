//
//  HighScoresView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//
import SwiftUI

struct HighScoresView: View {
    @StateObject private var viewModel: HighScoresViewModel

    init(viewModel: HighScoresViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Best Times")
                .font(ThemeFont.title(32))
                .foregroundColor(.white)

            ScoreCard(
                size: "3 x 3",
                time: viewModel.bestTime(for: 3),
                moves: viewModel.bestMoves(for: 3)
            )
            ScoreCard(
                size: "4 x 4",
                time: viewModel.bestTime(for: 4),
                moves: viewModel.bestMoves(for: 4)
            )
            ScoreCard(
                size: "5 x 5",
                time: viewModel.bestTime(for: 5),
                moves: viewModel.bestMoves(for: 5)
            )

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.spaceBlack.ignoresSafeArea())
        .navigationTitle("High Scores")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadScores()
        }
    }
}
