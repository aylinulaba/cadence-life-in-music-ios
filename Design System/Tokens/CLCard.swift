//
//  CLCard.swift
//  CadenceLifeInMusic
//
//  Created by Aylin ULABA on 2.09.2025.
//

import SwiftUI

// MARK: - Cadence Life Card
struct CLCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.vertical, Spacing.xl)
            .padding(.horizontal, Spacing.xl)
            .background(Color.surfaceLight)
            .cornerRadius(Radius.card)
            .cardShadow()
    }
}
