import Foundation

public struct Player: Identifiable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var gender: Gender
    public var avatarID: String
    public var currentCityID: UUID
    
    // Core Attributes
    public var health: Int // 0-100
    public var mood: Int // 0-100
    public var fame: Int // 0-∞
    public var reputation: Int // 0-100
    
    // Timestamps
    public var createdAt: Date
    public var lastSyncAt: Date
    
    // Activity State
    public var primaryFocusID: UUID?
    public var freeTimeActivityID: UUID?
    
    public enum Gender: String, Codable, CaseIterable, Sendable {
        case male
        case female
        case nonBinary
        
        public var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .nonBinary: return "Non-binary"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        gender: Gender,
        avatarID: String,
        currentCityID: UUID,
        health: Int = 80,
        mood: Int = 70,
        fame: Int = 0,
        reputation: Int = 50,
        createdAt: Date = Date(),
        lastSyncAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.gender = gender
        self.avatarID = avatarID
        self.currentCityID = currentCityID
        self.health = health
        self.mood = mood
        self.fame = fame
        self.reputation = reputation
        self.createdAt = createdAt
        self.lastSyncAt = lastSyncAt
    }
}

// MARK: - Computed Properties
extension Player {
    public var healthStatus: HealthStatus {
        switch health {
        case 0..<20: return .critical
        case 20..<40: return .poor
        case 40..<60: return .fair
        case 60..<80: return .good
        default: return .excellent
        }
    }
    
    public var moodStatus: MoodStatus {
        switch mood {
        case 0..<20: return .depressed
        case 20..<40: return .sad
        case 40..<60: return .neutral
        case 60..<80: return .happy
        default: return .euphoric
        }
    }
    
    public enum HealthStatus: String, Sendable {
        case critical, poor, fair, good, excellent
        
        public var emoji: String {
            switch self {
            case .critical: return "💀"
            case .poor: return "🤒"
            case .fair: return "😐"
            case .good: return "😊"
            case .excellent: return "💪"
            }
        }
    }
    
    public enum MoodStatus: String, Sendable {
        case depressed, sad, neutral, happy, euphoric
        
        public var emoji: String {
            switch self {
            case .depressed: return "😢"
            case .sad: return "😔"
            case .neutral: return "😐"
            case .happy: return "😊"
            case .euphoric: return "🤩"
            }
        }
    }
}
