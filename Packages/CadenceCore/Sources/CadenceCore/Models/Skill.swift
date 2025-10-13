import Foundation

public struct Skill: Identifiable, Codable, Sendable {
    public let id: UUID
    public let playerID: UUID
    public let skillType: SkillType
    public var currentXP: Int
    public var currentLevel: Int
    
    public enum SkillType: String, Codable, CaseIterable, Sendable {
        case guitar
        case piano
        case drums
        case bass
        case songwriting
        case performance
        case production
        
        public var displayName: String {
            rawValue.capitalized
        }
        
        public var emoji: String {
            switch self {
            case .guitar: return "🎸"
            case .piano: return "🎹"
            case .drums: return "🥁"
            case .bass: return "🎸"
            case .songwriting: return "✍️"
            case .performance: return "🎤"
            case .production: return "🎛️"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        playerID: UUID,
        skillType: SkillType,
        currentXP: Int = 0,
        currentLevel: Int = 0
    ) {
        self.id = id
        self.playerID = playerID
        self.skillType = skillType
        self.currentXP = currentXP
        self.currentLevel = currentLevel
    }
}

// MARK: - Progression Calculations
extension Skill {
    /// XP required to reach a specific level
    /// Formula: 100 × level^1.5
    public static func xpRequired(for level: Int) -> Int {
        Int(100.0 * pow(Double(level), 1.5))
    }
    
    /// XP needed to reach next level from current XP
    public var xpToNextLevel: Int {
        let nextLevelXP = Self.xpRequired(for: currentLevel + 1)
        let currentLevelXP = Self.xpRequired(for: currentLevel)
        return nextLevelXP - currentLevelXP
    }
    
    /// Progress to next level (0.0 to 1.0)
    public var progressToNextLevel: Double {
        let currentLevelXP = Self.xpRequired(for: currentLevel)
        let nextLevelXP = Self.xpRequired(for: currentLevel + 1)
        let xpInCurrentLevel = currentXP - currentLevelXP
        let xpNeededForLevel = nextLevelXP - currentLevelXP
        return Double(xpInCurrentLevel) / Double(xpNeededForLevel)
    }
    
    /// Add XP and automatically level up if threshold reached
    public mutating func addXP(_ amount: Int) {
        currentXP += amount
        
        // Check for level up
        while currentXP >= Self.xpRequired(for: currentLevel + 1) && currentLevel < 100 {
            currentLevel += 1
        }
    }
}
