//
//  SettingsStorageService.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation

final class SettingsStorageService {
    private let key = "snappuzzler.settings"

    func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return .default
        }

        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            print("Failed to decode settings: \(error)")
            return .default
        }
    }

    func saveSettings(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to encode settings: \(error)")
        }
    }
}
