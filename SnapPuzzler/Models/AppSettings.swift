//
//  AppSettings.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation

struct AppSettings: Codable {
    var defaultGridSize: Int
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var holdToCaptureDuration: Double

    static let `default` = AppSettings(
        defaultGridSize: 3,
        hapticsEnabled: true,
        soundEnabled: true,
        holdToCaptureDuration: 0.8
    )
}
