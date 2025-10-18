import Foundation

public struct Recording: Identifiable, Codable, Sendable {
    public let id: UUID
    public let songID: UUID
    public let playerID: UUID
    public var quality: Int // 0-100
    public let studioTier: StudioTier
    public let recordedAt: Date
    public var isReleased: Bool
    
    public enum StudioTier: String, Codable, CaseIterable, Sendable {
        case basic = "Basic Home Studio"
        case professional = "Professional Studio"
        case legendary = "Legendary Studio"
        
        public var hourlyRate: Int {
            switch self {
            case .basic: return 50
            case .professional: return 150
            case .legendary: return 500
            }
        }
        
        public var qualityCap: Int {
            switch self {
            case .basic: return 60
            case .professional: return 85
            case .legendary: return 100
            }
        }
        
        public var emoji: String {
            switch self {
            case .basic: return "🏠"
            case .professional: return "🎙️"
            case .legendary: return "⭐"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        songID: UUID,
        playerID: UUID,
        quality: Int,
        studioTier: StudioTier,
        recordedAt: Date = Date(),
        isReleased: Bool = false
    ) {
        self.id = id
        self.songID = songID
        self.playerID = playerID
        self.quality = quality
        self.studioTier = studioTier
        self.recordedAt = recordedAt
        self.isReleased = isReleased
    }
}
