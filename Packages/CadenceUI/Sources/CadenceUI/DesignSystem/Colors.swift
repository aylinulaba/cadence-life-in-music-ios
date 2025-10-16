import SwiftUI

public extension Color {
    // MARK: - Brand Colors
    static let cadencePrimary = Color(red: 0.2, green: 0.4, blue: 0.8) // Blue
    static let cadenceAccent = Color(red: 0.9, green: 0.3, blue: 0.5) // Pink
    
    // MARK: - Status Colors
    static let healthCritical = Color.red
    static let healthPoor = Color.orange
    static let healthFair = Color.yellow
    static let healthGood = Color.green
    static let healthExcellent = Color.blue
    
    static let moodDepressed = Color(red: 0.3, green: 0.3, blue: 0.4)
    static let moodSad = Color(red: 0.5, green: 0.5, blue: 0.6)
    static let moodNeutral = Color.gray
    static let moodHappy = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let moodEuphoric = Color(red: 1.0, green: 0.6, blue: 0.0)
    
    // MARK: - UI Elements
    static let cardBackground = Color(uiColor: .secondarySystemBackground)
    static let divider = Color(uiColor: .separator)
}

// MARK: - ShapeStyle Extension
public extension ShapeStyle where Self == Color {
    static var cadencePrimary: Color { Color.cadencePrimary }
    static var cadenceAccent: Color { Color.cadenceAccent }
}
