import Foundation

public final class RecordingManager: Sendable {
    
    private let healthMoodManager = HealthMoodManager()
    
    public init() {}
    
    /// Calculate recording quality
    public func calculateRecordingQuality(
        songQuality: Int,
        performanceSkill: Int,
        productionSkill: Int,
        studioTier: Recording.StudioTier,
        playerHealth: Int,
        playerMood: Int
    ) -> Int {
        // Song quality (40% weight)
        let songComponent = Double(songQuality) * 0.4
        
        // Performance skill (30% weight)
        let performanceComponent = Double(performanceSkill) * 0.3
        
        // Production skill (20% weight)
        let productionComponent = Double(productionSkill) * 0.2
        
        // Studio tier bonus (10% weight)
        let studioBonus = Double(studioTier.qualityCap) * 0.1
        
        let baseQuality = songComponent + performanceComponent + productionComponent + studioBonus
        
        // NEW: Apply health and mood modifiers
        let healthMoodModifier = healthMoodManager.getRecordingQualityModifier(
            health: playerHealth,
            mood: playerMood
        )
        
        let modifiedQuality = baseQuality * healthMoodModifier
        
        // Cap at studio tier maximum
        return Int(min(Double(studioTier.qualityCap), max(0, modifiedQuality)))
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
        
        // Calculate recording quality with health/mood impact
        let quality = calculateRecordingQuality(
            songQuality: song.quality,
            performanceSkill: performanceSkill,
            productionSkill: productionSkill,
            studioTier: studioTier,
            playerHealth: gameState.player.health,
            playerMood: gameState.player.mood
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
        
        // NEW: Apply health/mood changes from recording session
        var updatedPlayer = gameState.player
        
        // Long sessions are tiring
        if hours > 4 {
            updatedPlayer.adjustHealth(by: -(hours - 4))
        }
        
        // Good quality recording boosts mood
        if quality >= 70 {
            updatedPlayer.adjustMood(by: 5)
        } else if quality < 40 {
            updatedPlayer.adjustMood(by: -3)
        }
        
        gameState.player = updatedPlayer
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
