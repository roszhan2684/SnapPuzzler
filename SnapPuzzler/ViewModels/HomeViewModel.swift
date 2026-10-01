//
//  HomeViewModel.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import Foundation
import Combine
final class HomeViewModel: ObservableObject {
    @Published var appTitle: String = "SNAPPUZZLER"
    @Published var tagline: String = "Frame reality. Snap it. Solve it."
    @Published var versionText: String = "Version 1"
}
