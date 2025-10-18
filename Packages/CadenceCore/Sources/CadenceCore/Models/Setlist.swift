import Foundation

public struct Setlist: Identifiable, Codable, Sendable {
    public let id: UUID
    public let playerID: UUID
    public var name: String
    public var songIDs: [UUID]
    public var quality: Int // 0-100, improved through rehearsals
    public var rehearsalHours: Double // Total hours rehearsed
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        playerID: UUID,
        name: String,
        songIDs: [UUID] = [],
        quality: Int = 0,
        rehearsalHours: Double = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.playerID = playerID
        self.name = name
        self.songIDs = songIDs
        self.quality = quality
        self.rehearsalHours = rehearsalHours
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties
extension Setlist {
    public var songCount: Int {
        songIDs.count
    }
    
    public var isReady: Bool {
        songCount >= 3 && quality >= 30
    }
    
    public var readinessStatus: String {
        if songCount < 3 {
            return "Need at least 3 songs"
        } else if quality < 40 {
            return "Needs more rehearsal"
        } else if quality < 60 {
            return "Ready for small venues"
        } else if quality < 80 {
            return "Ready for mid venues"
        } else {
            return "Ready for any venue"
        }
    }
}
