import Foundation

public struct Player: Identifiable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var gender: Gender
    public var avatarID: String
    public var currentCityID: UUID
    public var health: Int
    public var mood: Int
    public var fame: Int
    public var reputation: Int
    public var lastSyncAt: Date
    
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
        self.lastSyncAt = lastSyncAt
    }
    
    // MARK: - Gender
    
    public enum Gender: String, Codable, CaseIterable, Sendable {
        case male
        case female
        case nonBinary = "non-binary"
        
        public var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .nonBinary: return "Non-binary"
            }
        }
    }
    
    // MARK: - Health Status (NEW)
    
    public var healthStatus: HealthStatus {
        switch health {
        case 0...20: return .critical
        case 21...40: return .poor
        case 41...60: return .fair
        case 61...80: return .good
        default: return .excellent
        }
    }
    
    public enum HealthStatus: String, Codable, Sendable {
        case critical
        case poor
        case fair
        case good
        case excellent
        
        public var emoji: String {
            switch self {
            case .critical: return "💀"
            case .poor: return "🤕"
            case .fair: return "😐"
            case .good: return "😊"
            case .excellent: return "💪"
            }
        }
        
        public var displayName: String {
            switch self {
            case .critical: return "Critical"
            case .poor: return "Poor"
            case .fair: return "Fair"
            case .good: return "Good"
            case .excellent: return "Excellent"
            }
        }
        
        public var description: String {
            switch self {
            case .critical: return "You need immediate rest!"
            case .poor: return "Your health is suffering"
            case .fair: return "Could be better"
            case .good: return "Feeling good"
            case .excellent: return "In peak condition!"
            }
        }
    }
    
    // MARK: - Mood Status (NEW)
    
    public var moodStatus: MoodStatus {
        switch mood {
        case 0...20: return .depressed
        case 21...40: return .sad
        case 41...60: return .neutral
        case 61...80: return .happy
        default: return .euphoric
        }
    }
    
    public enum MoodStatus: String, Codable, Sendable {
        case depressed
        case sad
        case neutral
        case happy
        case euphoric
        
        public var emoji: String {
            switch self {
            case .depressed: return "😢"
            case .sad: return "😔"
            case .neutral: return "😐"
            case .happy: return "😊"
            case .euphoric: return "🤩"
            }
        }
        
        public var displayName: String {
            switch self {
            case .depressed: return "Depressed"
            case .sad: return "Sad"
            case .neutral: return "Neutral"
            case .happy: return "Happy"
            case .euphoric: return "Euphoric"
            }
        }
        
        public var description: String {
            switch self {
            case .depressed: return "Feeling very down"
            case .sad: return "Not feeling great"
            case .neutral: return "Feeling okay"
            case .happy: return "Feeling good!"
            case .euphoric: return "On top of the world!"
            }
        }
    }
    
    // MARK: - Health & Mood Modifiers (NEW)
    
    /// Overall performance effectiveness (0.0 to 1.0+)
    public var performanceMultiplier: Double {
        let healthFactor = Double(health) / 100.0
        let moodFactor = Double(mood) / 100.0
        return (healthFactor + moodFactor) / 2.0
    }
    
    /// Whether player should be warned about low health
    public var needsHealthWarning: Bool {
        health < 30
    }
    
    /// Whether player should be warned about low mood
    public var needsMoodWarning: Bool {
        mood < 30
    }
    
    /// Whether player is in critical condition
    public var isInCriticalCondition: Bool {
        health < 20 || mood < 20
    }
    
    // MARK: - Health & Mood Management (NEW)
    
    /// Apply health change with bounds checking
    public mutating func adjustHealth(by amount: Int) {
        health = min(100, max(0, health + amount))
    }
    
    /// Apply mood change with bounds checking
    public mutating func adjustMood(by amount: Int) {
        mood = min(100, max(0, mood + amount))
    }
    
    /// Rest to recover health and mood
    public mutating func rest(hours: Double) {
        let healthGain = Int(hours * 10)
        let moodGain = Int(hours * 5)
        
        adjustHealth(by: healthGain)
        adjustMood(by: moodGain)
    }
    
    /// Apply overwork penalty
    public mutating func applyOverworkPenalty(hours: Double) {
        if hours > 8 {
            let excessHours = hours - 8
            let healthLoss = Int(excessHours * 2)
            let moodLoss = Int(excessHours * 1)
            
            adjustHealth(by: -healthLoss)
            adjustMood(by: -moodLoss)
        }
    }
    
    /// Apply passive decay over time
    public mutating func applyPassiveDecay(hours: Double) {
        let healthLoss = Int(hours * (2.0 / 24.0))
        let moodLoss = Int(hours * (1.0 / 24.0))
        
        adjustHealth(by: -healthLoss)
        adjustMood(by: -moodLoss)
    }
}
