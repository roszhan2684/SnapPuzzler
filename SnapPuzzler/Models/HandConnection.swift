//
//  HandConnection.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 15/03/26.
//

import Foundation

struct HandConnection: Identifiable, Equatable {
    let id = UUID()
    let from: HandPoint
    let to: HandPoint
}
