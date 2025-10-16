import Foundation

public struct TimeSlot: Identifiable, Codable, Sendable {
    public let id: UUID
    public let playerID: UUID
    public let slotType: SlotType
    public var currentActivity: Activity?
    public var startedAt: Date?
    
    public enum SlotType: String, Codable, Sendable {
        case primaryFocus
        case freeTime
        
        public var displayName: String {
            switch self {
            case .primaryFocus: return "Primary Focus"
            case .freeTime: return "Free Time"
            }
        }
        
        public var description: String {
            switch self {
            case .primaryFocus:
                return "Your main activity. Choose a job for income or focus on music."
            case .freeTime:
                return "Side activity. Practice, rest, or socialize."
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        playerID: UUID,
        slotType: SlotType,
        currentActivity: Activity? = nil,
        startedAt: Date? = nil
    ) {
        self.id = id
        self.playerID = playerID
        self.slotType = slotType
        self.currentActivity = currentActivity
        self.startedAt = startedAt
    }
}

// MARK: - Progress Calculation
extension TimeSlot {
    /// Calculate elapsed time since activity started
    public var elapsedTime: TimeInterval {
        guard let startedAt = startedAt else { return 0 }
        return Date().timeIntervalSince(startedAt)
    }
    
    /// Check if slot has an active activity
    public var isActive: Bool {
        currentActivity != nil && startedAt != nil
    }
    
    /// Formatted elapsed time (e.g., "2h 30m")
    public var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
