//
//  RootView.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeView(viewModel: HomeViewModel())
        }
        .tint(Theme.neonCoral)
        .background(Theme.spaceBlack)
    }
}
