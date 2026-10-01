//
//  GameMode.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation

enum GameMode: Int, CaseIterable, Identifiable {
    case threeByThree = 3
    case fourByFour = 4
    case fiveByFive = 5

    var id: Int { rawValue }

    var title: String {
        "\(rawValue) x \(rawValue)"
    }
}
