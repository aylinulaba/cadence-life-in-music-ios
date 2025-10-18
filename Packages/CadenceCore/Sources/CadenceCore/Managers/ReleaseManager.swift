import Foundation

public final class ReleaseManager: Sendable {
    public init() {}
    
    /// Create and publish a release
    public func publishRelease(
        gameState: inout GameState,
        title: String,
        type: Release.ReleaseType,
        recordingIDs: [UUID]
    ) throws {
        // Validate minimum tracks
        guard recordingIDs.count >= type.minTracks else {
            throw ReleaseError.insufficientTracks(required: type.minTracks, provided: recordingIDs.count)
        }
        
        // Check all recordings exist and are unreleased
        for recordingID in recordingIDs {
            guard let recording = gameState.recording(for: recordingID) else {
                throw ReleaseError.recordingNotFound
            }
            
            if recording.isReleased {
                throw ReleaseError.recordingAlreadyReleased
            }
        }
        
        // Create release
        let release = Release(
            playerID: gameState.player.id,
            title: title,
            type: type,
            recordingIDs: recordingIDs
        )
        
        gameState.addRelease(release)
        
        // Mark recordings as released
        for recordingID in recordingIDs {
            if var recording = gameState.recording(for: recordingID) {
                recording.isReleased = true
                gameState.updateRecording(recording)
            }
        }
        
        // Mark songs as released
        for recordingID in recordingIDs {
            if let recording = gameState.recording(for: recordingID),
               var song = gameState.song(for: recording.songID) {
                song.isReleased = true
                gameState.updateSong(song)
            }
        }
        
        // Grant fame based on release type and quality
        let avgQuality = calculateAverageQuality(gameState: gameState, recordingIDs: recordingIDs)
        let fameGain = type == .single ? avgQuality / 10 : avgQuality / 5
        gameState.player.fame += fameGain
    }
    
    /// Calculate average recording quality
    private func calculateAverageQuality(gameState: GameState, recordingIDs: [UUID]) -> Int {
        let recordings = recordingIDs.compactMap { gameState.recording(for: $0) }
        guard !recordings.isEmpty else { return 0 }
        return recordings.map { $0.quality }.reduce(0, +) / recordings.count
    }
    
    /// Simulate weekly plays and revenue
    public func processWeeklyStreaming(gameState: inout GameState) {
        for var release in gameState.releases {
            // Calculate plays based on fame and quality
            let avgQuality = calculateAverageQuality(gameState: gameState, recordingIDs: release.recordingIDs)
            let basePlays = gameState.player.fame * 10 + avgQuality * 5
            let randomMultiplier = Double.random(in: 0.8...1.2)
            let weeklyPlays = Int(Double(basePlays) * randomMultiplier)
            
            release.totalPlays += weeklyPlays
            
            // Revenue: $0.01-0.10 per play based on quality
            let revenuePerPlay = Decimal(avgQuality) / 1000.0
            let weeklyRevenue = revenuePerPlay * Decimal(weeklyPlays)
            
            release.totalRevenue += weeklyRevenue
            gameState.updateRelease(release)
            
            // Add to wallet
            gameState.wallet.addIncome(weeklyRevenue)
        }
    }
    
    public enum ReleaseError: Error, LocalizedError {
        case insufficientTracks(required: Int, provided: Int)
        case recordingNotFound
        case recordingAlreadyReleased
        
        public var errorDescription: String? {
            switch self {
            case .insufficientTracks(let required, let provided):
                return "Need at least \(required) tracks, but only \(provided) provided"
            case .recordingNotFound:
                return "One or more recordings not found"
            case .recordingAlreadyReleased:
                return "Recording already released"
            }
        }
    }
}
