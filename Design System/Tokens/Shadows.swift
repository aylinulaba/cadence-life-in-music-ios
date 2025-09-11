//
//  Shadows.swift
//  CadenceLifeInMusic
//
//  Created by Aylin ULABA on 2.09.2025.
//

import SwiftUI

// MARK: - Global Shadows

extension View {
    /// Card-level shadow: #111827 @ 12%, y:10, blur:24
    func cardShadow() -> some View {
        self.shadow(
            color: Color.textPrimary.opacity(0.12),
            radius: 24,
            x: 0,
            y: 10
        )
    }
}
