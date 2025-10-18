import Foundation

public final class SetlistManager: Sendable {
    public init() {}
    
    /// Create a new setlist
    public func createSetlist(
        gameState: inout GameState,
        name: String,
        songIDs: [UUID]
    ) {
        let setlist = Setlist(
            playerID: gameState.player.id,
            name: name,
            songIDs: songIDs
        )
        
        gameState.addSetlist(setlist)
    }
    
    /// Calculate setlist base quality from songs
    public func calculateBaseQuality(songs: [Song]) -> Int {
        guard !songs.isEmpty else { return 0 }
        let avgQuality = songs.map { $0.quality }.reduce(0, +) / songs.count
        return avgQuality
    }
    
    /// Rehearse setlist and improve quality
    public func rehearse(
        gameState: inout GameState,
        setlistID: UUID,
        hours: Double
    ) {
        guard var setlist = gameState.setlist(for: setlistID) else { return }
        
        // Add rehearsal hours
        setlist.rehearsalHours += hours
        
        // Improve quality: +10 points per hour, capped at +40 bonus
        let rehearsalBonus = min(Int(setlist.rehearsalHours * 10), 40)
        
        // Get songs in setlist
        let songs = setlist.songIDs.compactMap { gameState.song(for: $0) }
        let baseQuality = calculateBaseQuality(songs: songs)
        
        // Performance skill bonus
        let performanceSkill = gameState.skill(for: .performance)?.currentLevel ?? 0
        let performanceBonus = Int(Double(performanceSkill) * 0.2)
        
        // Calculate final quality
        setlist.quality = min(100, baseQuality + rehearsalBonus + performanceBonus)
        setlist.updatedAt = Date()
        
        gameState.updateSetlist(setlist)
        
        // Grant performance XP
        if var skill = gameState.skill(for: .performance) {
            let xpGain = Int(hours * 5) // 5 XP per hour of rehearsal
            skill.addXP(xpGain)
            gameState.updateSkill(skill)
        }
    }
}
