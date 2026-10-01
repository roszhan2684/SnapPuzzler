//
//  HandPoint.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 15/03/26.
//

import Foundation
import CoreGraphics

struct HandPoint: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let point: CGPoint
    let confidence: Float
}
