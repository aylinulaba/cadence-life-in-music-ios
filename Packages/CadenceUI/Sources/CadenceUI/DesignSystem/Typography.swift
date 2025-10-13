import SwiftUI

public extension Font {
    // MARK: - Headings
    static let cadenceTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let cadenceHeadline = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let cadenceSubheadline = Font.system(size: 18, weight: .medium, design: .rounded)
    
    // MARK: - Body
    static let cadenceBody = Font.system(size: 16, weight: .regular, design: .default)
    static let cadenceBodyBold = Font.system(size: 16, weight: .semibold, design: .default)
    
    // MARK: - Special
    static let cadenceCaption = Font.system(size: 12, weight: .regular, design: .default)
    static let cadenceStat = Font.system(size: 48, weight: .bold, design: .rounded)
}
