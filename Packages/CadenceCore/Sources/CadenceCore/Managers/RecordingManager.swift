import Foundation

public final class RecordingManager: Sendable {
    public init() {}
    
    /// Calculate recording quality
    public func calculateRecordingQuality(
        songQuality: Int,
        performanceSkill: Int,
        productionSkill: Int,
        studioTier: Recording.StudioTier
    ) -> Int {
        // Song quality (40% weight)
        let songComponent = Double(songQuality) * 0.4
        
        // Performance skill (30% weight)
        let performanceComponent = Double(performanceSkill) * 0.3
        
        // Production skill (20% weight)
        let productionComponent = Double(productionSkill) * 0.2
        
        // Studio tier bonus (10% weight)
        let studioBonus = Double(studioTier.qualityCap) * 0.1
        
        let totalQuality = songComponent + performanceComponent + productionComponent + studioBonus
        
        // Cap at studio tier maximum
        return Int(min(Double(studioTier.qualityCap), max(0, totalQuality)))
    }
    
    /// Record a song
    public func recordSong(
        gameState: inout GameState,
        songID: UUID,
        studioTier: Recording.StudioTier,
        hours: Int
    ) throws {
        guard let song = gameState.song(for: songID) else {
            throw RecordingError.songNotFound
        }
        
        // Calculate cost
        let cost = Decimal(studioTier.hourlyRate * hours)
        
        // Check if player can afford it
        guard gameState.wallet.balance >= cost else {
            throw RecordingError.insufficientFunds
        }
        
        // Deduct cost
        try gameState.wallet.deductExpense(cost)
        
        // Get skills
        let performanceSkill = gameState.skill(for: .performance)?.currentLevel ?? 0
        let productionSkill = gameState.skill(for: .production)?.currentLevel ?? 0
        
        // Calculate recording quality
        let quality = calculateRecordingQuality(
            songQuality: song.quality,
            performanceSkill: performanceSkill,
            productionSkill: productionSkill,
            studioTier: studioTier
        )
        
        // Create recording
        let recording = Recording(
            songID: songID,
            playerID: gameState.player.id,
            quality: quality,
            studioTier: studioTier
        )
        
        gameState.addRecording(recording)
        
        // Update song with recording ID
        var updatedSong = song
        updatedSong.recordingID = recording.id
        gameState.updateSong(updatedSong)
        
        // Grant production XP
        if var skill = gameState.skill(for: .production) {
            let xpGain = hours * 10 // 10 XP per hour
            skill.addXP(xpGain)
            gameState.updateSkill(skill)
        }
    }
    
    public enum RecordingError: Error, LocalizedError {
        case songNotFound
        case insufficientFunds
        case songAlreadyRecorded
        
        public var errorDescription: String? {
            switch self {
            case .songNotFound:
                return "Song not found"
            case .insufficientFunds:
                return "Not enough money to record"
            case .songAlreadyRecorded:
                return "Song already has a recording"
            }
        }
    }
}
