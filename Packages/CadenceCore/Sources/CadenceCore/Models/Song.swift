import Foundation

public struct Song: Identifiable, Codable, Sendable {
    public let id: UUID
    public let authorID: UUID
    public var title: String
    public let genre: MusicGenre
    public let mood: SongMood
    public var quality: Int // 0-100
    public let createdAt: Date
    public var recordingID: UUID?
    public var isReleased: Bool
    
    public enum MusicGenre: String, Codable, CaseIterable, Sendable {
        case pop = "Pop"
        case rock = "Rock"
        case jazz = "Jazz"
        case hipHop = "Hip-Hop"
        case electronic = "Electronic"
        case folk = "Folk"
        
        public var emoji: String {
            switch self {
            case .pop: return "🎤"
            case .rock: return "🎸"
            case .jazz: return "🎷"
            case .hipHop: return "🎧"
            case .electronic: return "🎹"
            case .folk: return "🪕"
            }
        }
    }
    
    public enum SongMood: String, Codable, CaseIterable, Sendable {
        case upbeat = "Upbeat"
        case melancholic = "Melancholic"
        case energetic = "Energetic"
        case calm = "Calm"
        
        public var emoji: String {
            switch self {
            case .upbeat: return "😊"
            case .melancholic: return "😔"
            case .energetic: return "⚡"
            case .calm: return "🌊"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        authorID: UUID,
        title: String,
        genre: MusicGenre,
        mood: SongMood,
        quality: Int,
        createdAt: Date = Date(),
        recordingID: UUID? = nil,
        isReleased: Bool = false
    ) {
        self.id = id
        self.authorID = authorID
        self.title = title
        self.genre = genre
        self.mood = mood
        self.quality = quality
        self.createdAt = createdAt
        self.recordingID = recordingID
        self.isReleased = isReleased
    }
}

// MARK: - Quality Tiers
extension Song {
    public var qualityTier: QualityTier {
        switch quality {
        case 0..<20: return .poor
        case 20..<40: return .average
        case 40..<60: return .good
        case 60..<80: return .great
        default: return .masterpiece
        }
    }
    
    public enum QualityTier: String, Sendable {
        case poor = "Poor"
        case average = "Average"
        case good = "Good"
        case great = "Great"
        case masterpiece = "Masterpiece"
        
        public var color: String {
            switch self {
            case .poor: return "gray"
            case .average: return "orange"
            case .good: return "blue"
            case .great: return "purple"
            case .masterpiece: return "yellow"
            }
        }
    }
}
