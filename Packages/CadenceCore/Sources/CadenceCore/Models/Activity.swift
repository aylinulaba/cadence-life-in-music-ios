import Foundation

public enum Activity: Codable, Sendable {
    case practice(instrument: Skill.SkillType)
    case rest
    case job(type: JobType)
    case rehearsal(setlistID: UUID)
    case gig(gigID: UUID)
    
    public enum JobType: String, Codable, Sendable {
        case cashier = "Cashier"
        case salesClerk = "Sales Clerk"
        case barista = "Barista"
        case waiter = "Waiter/Waitress"
        
        public var weeklySalary: Decimal {
            switch self {
            case .cashier: return 150
            case .salesClerk: return 150
            case .barista: return 175
            case .waiter: return 200
            }
        }
    }
    
    public var type: ActivityType {
        switch self {
        case .practice:
            return .practice
        case .rest:
            return .rest
        case .job:
            return .job
        case .rehearsal:
            return .rehearsal
        case .gig:
            return .gig
        }
    }
    
    public var name: String {
        switch self {
        case .practice(let instrument):
            return "Practice \(instrument.displayName)"
        case .rest:
            return "Rest"
        case .job(let jobType):
            return jobType.rawValue
        case .rehearsal:
            return "Rehearsal"
        case .gig:
            return "Performance"
        }
    }
    
    public var description: String {
        switch self {
        case .practice(let instrument):
            return "Improve your \(instrument.displayName) skills. +10 XP/hour."
        case .rest:
            return "Recover health and mood. +10 Health, +5 Mood per hour."
        case .job(let jobType):
            return "Earn $\(jobType.weeklySalary)/week"
        case .rehearsal:
            return "Improve setlist quality"
        case .gig:
            return "Perform live"
        }
    }
    
    public enum ActivityType: String, Codable, Sendable {
        case practice
        case rest
        case job
        case rehearsal
        case gig
    }
}
