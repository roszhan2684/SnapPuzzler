//
//  SettingsView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Game") {
                Picker("Default Grid Size", selection: $viewModel.settings.defaultGridSize) {
                    Text("3 x 3").tag(3)
                    Text("4 x 4").tag(4)
                    Text("5 x 5").tag(5)
                }

                Slider(
                    value: $viewModel.settings.holdToCaptureDuration,
                    in: 0.5...2.0,
                    step: 0.1
                ) {
                    Text("Hold Duration")
                }

                Text("Capture Hold Duration: \(viewModel.settings.holdToCaptureDuration, specifier: "%.1f") sec")
                    .font(ThemeFont.body(12))
                    .foregroundColor(.white.opacity(0.6))
            }

            Section("Feedback") {
                Toggle("Haptics", isOn: $viewModel.settings.hapticsEnabled)
                Toggle("Sound", isOn: $viewModel.settings.soundEnabled)
            }

            Section("Actions") {
                Button("Save Settings") {
                    viewModel.save()
                }

                Button("Reset to Defaults", role: .destructive) {
                    viewModel.resetToDefaults()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.spaceBlack.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.neonCoral)
    }
}
