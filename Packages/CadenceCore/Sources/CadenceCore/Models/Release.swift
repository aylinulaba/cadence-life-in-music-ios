import Foundation

public struct Release: Identifiable, Codable, Sendable {
    public let id: UUID
    public let playerID: UUID
    public var title: String
    public let type: ReleaseType
    public let recordingIDs: [UUID]
    public let releasedAt: Date
    public var totalPlays: Int
    public var totalRevenue: Decimal
    
    public enum ReleaseType: String, Codable, Sendable {
        case single = "Single"
        case album = "Album"
        
        public var minTracks: Int {
            switch self {
            case .single: return 1
            case .album: return 5
            }
        }
        
        public var emoji: String {
            switch self {
            case .single: return "💿"
            case .album: return "📀"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        playerID: UUID,
        title: String,
        type: ReleaseType,
        recordingIDs: [UUID],
        releasedAt: Date = Date(),
        totalPlays: Int = 0,
        totalRevenue: Decimal = 0
    ) {
        self.id = id
        self.playerID = playerID
        self.title = title
        self.type = type
        self.recordingIDs = recordingIDs
        self.releasedAt = releasedAt
        self.totalPlays = totalPlays
        self.totalRevenue = totalRevenue
    }
}
