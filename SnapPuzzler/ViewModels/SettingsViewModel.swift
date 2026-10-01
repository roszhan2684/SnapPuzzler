//
//  SettingsViewModel.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation
import Combine
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings

    private let storageService: SettingsStorageService

    init(storageService: SettingsStorageService = SettingsStorageService()) {
        self.storageService = storageService
        self.settings = storageService.loadSettings()
    }

    func save() {
        storageService.saveSettings(settings)
    }

    func resetToDefaults() {
        settings = .default
        save()
    }
}
