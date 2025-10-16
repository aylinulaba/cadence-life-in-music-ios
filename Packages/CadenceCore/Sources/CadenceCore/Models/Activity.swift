import Foundation

public struct Activity: Identifiable, Codable, Sendable {
    public let id: UUID
    public let type: ActivityType
    public let name: String
    public let description: String
    public var startedAt: Date?
    public var duration: TimeInterval // in seconds
    
    public enum ActivityType: String, Codable, Sendable {
        case job
        case practice
        case rest
        case songwriting
        case rehearsal
        case recording
        case gig
        
        public var icon: String {
            switch self {
            case .job: return "briefcase.fill"
            case .practice: return "music.note"
            case .rest: return "bed.double.fill"
            case .songwriting: return "pencil.and.outline"
            case .rehearsal: return "music.mic"
            case .recording: return "waveform"
            case .gig: return "sparkles"
            }
        }
        
        public var category: ActivityCategory {
            switch self {
            case .job: return .income
            case .practice, .songwriting, .rehearsal: return .skill
            case .rest: return .recovery
            case .recording, .gig: return .performance
            }
        }
    }
    
    public enum ActivityCategory: String, Codable, Sendable {
        case income
        case skill
        case recovery
        case performance
    }
    
    public init(
        id: UUID = UUID(),
        type: ActivityType,
        name: String,
        description: String,
        startedAt: Date? = nil,
        duration: TimeInterval = 0
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.startedAt = startedAt
        self.duration = duration
    }
}

// MARK: - Predefined Activities
extension Activity {
    // Jobs
    public static let cashierJob = Activity(
        type: .job,
        name: "Cashier",
        description: "Work at a supermarket. Earn $150/week."
    )
    
    public static let baristaJob = Activity(
        type: .job,
        name: "Barista",
        description: "Work at a coffee shop. Earn $180/week."
    )
    
    public static let waiterJob = Activity(
        type: .job,
        name: "Waiter",
        description: "Work at a restaurant. Earn $200/week."
    )
    
    // Practice Activities
    public static func practice(instrument: Skill.SkillType) -> Activity {
        Activity(
            type: .practice,
            name: "Practice \(instrument.displayName)",
            description: "Improve your \(instrument.displayName) skills. +10 XP/hour."
        )
    }
    
    // Rest
    public static let rest = Activity(
        type: .rest,
        name: "Rest",
        description: "Recover health and mood. +10 health/hour, +5 mood/hour."
    )
    
    public static let allJobs: [Activity] = [
        .cashierJob,
        .baristaJob,
        .waiterJob
    ]
}
