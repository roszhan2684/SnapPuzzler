//
//  HomeView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 10) {
                    Text(viewModel.appTitle)
                        .font(ThemeFont.title(36))
                        .foregroundColor(.white)

                    Text(viewModel.tagline)
                        .font(ThemeFont.body(15))
                        .foregroundColor(.white.opacity(0.75))
                }

                VStack(spacing: 16) {
                    NavigationLink(destination: GameView(viewModel: GameViewModel())) {
                        HomeButton(title: "Start Game", systemImage: "play.fill")
                    }

                    NavigationLink(destination: HowToPlayView()) {
                        HomeButton(title: "How To Play", systemImage: "hand.draw.fill")
                    }

                    NavigationLink(destination: HighScoresView(viewModel: HighScoresViewModel())) {
                        HomeButton(title: "High Scores", systemImage: "clock.fill")
                    }

                    NavigationLink(destination: SettingsView(viewModel: SettingsViewModel())) {
                        HomeButton(title: "Settings", systemImage: "gearshape.fill")
                    }

                    NavigationLink(destination: AboutView()) {
                        HomeButton(title: "About", systemImage: "info.circle.fill")
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                Text(viewModel.versionText)
                    .font(ThemeFont.body(12))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
