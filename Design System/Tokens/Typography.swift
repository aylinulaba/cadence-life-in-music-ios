//
//  Typography.swift
//  CadenceLifeInMusic
//
//  Created by Aylin ULABA on 2.09.2025.
//

import SwiftUI

// MARK: - Poppins helpers
enum Poppins {
    static func light(_ size: CGFloat)     -> Font { .custom("Poppins-Light", size: size) }
    static func regular(_ size: CGFloat)   -> Font { .custom("Poppins-Regular", size: size) }
    static func medium(_ size: CGFloat)    -> Font { .custom("Poppins-Medium", size: size) }
    static func semiBold(_ size: CGFloat)  -> Font { .custom("Poppins-SemiBold", size: size) }
    static func lightItalic(_ size: CGFloat) -> Font { .custom("Poppins-LightItalic", size: size) }
}

// MARK: - Type scale
struct TypeScale {
    static let h1 = Poppins.semiBold(36)
    static let h2 = Poppins.semiBold(28)
    static let h3 = Poppins.medium(22)

    static let body   = Poppins.regular(16)
    static let small  = Poppins.light(14)
    static let button = Poppins.semiBold(16)
}

// MARK: - Quick access modifiers
extension View {
    func typeH1() -> some View { self.font(TypeScale.h1) }
    func typeH2() -> some View { self.font(TypeScale.h2) }
    func typeH3() -> some View { self.font(TypeScale.h3) }
    func typeBody() -> some View { self.font(TypeScale.body) }
    func typeSmall() -> some View { self.font(TypeScale.small) }
    func typeButton() -> some View { self.font(TypeScale.button) }
}
