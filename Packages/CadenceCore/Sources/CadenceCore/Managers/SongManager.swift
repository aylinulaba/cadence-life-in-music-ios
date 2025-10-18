import Foundation

public final class SongManager: Sendable {
    public init() {}
    
    /// Calculate song quality based on player skills and mood
    public func calculateSongQuality(
        songwritingSkill: Int,
        instrumentSkill: Int,
        playerMood: Int
    ) -> Int {
        // Base quality from songwriting skill (40% weight)
        let songwritingComponent = Double(songwritingSkill) * 0.4
        
        // Instrument proficiency (30% weight)
        let instrumentComponent = Double(instrumentSkill) * 0.3
        
        // Mood influence (20% weight)
        let moodComponent = Double(playerMood) * 0.2
        
        // Random variance (10% weight, ±10 points)
        let randomVariance = Double.random(in: -10...10) * 0.1
        
        let totalQuality = songwritingComponent + instrumentComponent + moodComponent + randomVariance
        
        return Int(max(0, min(100, totalQuality)))
    }
    
    /// Create a new song and grant XP
    public func createSong(
        gameState: inout GameState,
        title: String,
        genre: Song.MusicGenre,
        mood: Song.SongMood,
        primaryInstrument: Skill.SkillType
    ) {
        let songwritingSkill = gameState.skill(for: .songwriting)?.currentLevel ?? 0
        let instrumentSkill = gameState.skill(for: primaryInstrument)?.currentLevel ?? 0
        
        let quality = calculateSongQuality(
            songwritingSkill: songwritingSkill,
            instrumentSkill: instrumentSkill,
            playerMood: gameState.player.mood
        )
        
        let song = Song(
            authorID: gameState.player.id,
            title: title,
            genre: genre,
            mood: mood,
            quality: quality
        )
        
        gameState.addSong(song)
        
        // Grant Songwriting XP
        if var skill = gameState.skill(for: .songwriting) {
            // Base XP: 20-50 depending on song quality
            let baseXP = 20 + (quality / 2) // 20-70 XP
            skill.addXP(baseXP)
            gameState.updateSkill(skill)
        }
        
        // Grant small XP to primary instrument
        if var instrumentSkillObj = gameState.skill(for: primaryInstrument) {
            let instrumentXP = 5 + (quality / 10) // 5-15 XP
            instrumentSkillObj.addXP(instrumentXP)
            gameState.updateSkill(instrumentSkillObj)
        }
    }
}
