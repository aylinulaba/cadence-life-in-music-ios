import Foundation
import SwiftUI
import CadenceCore

@Observable
final class GameStateViewModel {
    var gameState: GameState
    var refreshTrigger: Int = 0
    
    private let progressionManager = IdleProgressionManager()
    private let songManager = SongManager()
    private let setlistManager = SetlistManager()
    private let recordingManager = RecordingManager()
    private let releaseManager = ReleaseManager()
    private let gigManager = GigManager()
    
    private var updateTimer: Timer?
    
    init(gameState: GameState) {
        self.gameState = gameState
        startProgressionTimer()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // MARK: - Idle Progression
    
    private func startProgressionTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.updateTimer = Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { timer in
                self?.updateProgress()
            }
            
            if let timer = self?.updateTimer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    func updateProgress() {
        progressionManager.processIdleProgress(gameState: &gameState)
        checkScheduledGigs()
        refreshTrigger += 1
    }
    
    // MARK: - Activity Management
    
    func setActivity(_ activity: Activity, in slotType: TimeSlot.SlotType) {
        switch slotType {
        case .primaryFocus:
            gameState.primaryFocus.currentActivity = activity
            gameState.primaryFocus.startedAt = Date()
        case .freeTime:
            gameState.freeTime.currentActivity = activity
            gameState.freeTime.startedAt = Date()
        }
        refreshTrigger += 1
    }
    
    func clearActivity(in slotType: TimeSlot.SlotType) {
        switch slotType {
        case .primaryFocus:
            gameState.primaryFocus.currentActivity = nil
            gameState.primaryFocus.startedAt = nil
        case .freeTime:
            gameState.freeTime.currentActivity = nil
            gameState.freeTime.startedAt = nil
        }
        refreshTrigger += 1
    }
    
    // MARK: - Skill Access
    
    func skill(for type: Skill.SkillType) -> Skill? {
        gameState.skill(for: type)
    }
    
    // MARK: - Economy
    
    func addIncome(_ amount: Decimal, description: String) {
        gameState.wallet.addIncome(amount)
        refreshTrigger += 1
    }
    
    func deductExpense(_ amount: Decimal, description: String) throws {
        try gameState.wallet.deductExpense(amount)
        refreshTrigger += 1
    }
    
    // MARK: - Song Management
    
    func createSong(
        title: String,
        genre: Song.MusicGenre,
        mood: Song.SongMood,
        primaryInstrument: Skill.SkillType
    ) {
        songManager.createSong(
            gameState: &gameState,
            title: title,
            genre: genre,
            mood: mood,
            primaryInstrument: primaryInstrument
        )
        refreshTrigger += 1
    }
    
    var songs: [Song] {
        gameState.songs
    }
    
    var unreleasedSongs: [Song] {
        gameState.unreleasedSongs
    }
    
    // MARK: - Setlist Management
    
    func createSetlist(name: String, songIDs: [UUID]) {
        setlistManager.createSetlist(
            gameState: &gameState,
            name: name,
            songIDs: songIDs
        )
        refreshTrigger += 1
    }
    
    func rehearseSetlist(setlistID: UUID, hours: Double) {
        setlistManager.rehearse(
            gameState: &gameState,
            setlistID: setlistID,
            hours: hours
        )
        refreshTrigger += 1
    }
    
    var setlists: [Setlist] {
        gameState.setlists
    }
    
    func setlist(for id: UUID) -> Setlist? {
        gameState.setlist(for: id)
    }
    
    // MARK: - Recording Management
    
    func recordSong(
        songID: UUID,
        studioTier: Recording.StudioTier,
        hours: Int
    ) throws {
        try recordingManager.recordSong(
            gameState: &gameState,
            songID: songID,
            studioTier: studioTier,
            hours: hours
        )
        refreshTrigger += 1
    }
    
    var recordings: [Recording] {
        gameState.recordings
    }
    
    var unreleasedRecordings: [Recording] {
        gameState.unreleasedRecordings
    }
    
    func recording(for id: UUID) -> Recording? {
        gameState.recording(for: id)
    }
    
    // MARK: - Release Management
    
    func publishRelease(
        title: String,
        type: Release.ReleaseType,
        recordingIDs: [UUID]
    ) throws {
        try releaseManager.publishRelease(
            gameState: &gameState,
            title: title,
            type: type,
            recordingIDs: recordingIDs
        )
        refreshTrigger += 1
    }
    
    var releases: [Release] {
        gameState.releases
    }
    
    // MARK: - Gig Management
    
    func bookGig(
        venue: Venue,
        setlistID: UUID,
        scheduledAt: Date,
        ticketPrice: Decimal
    ) throws {
        try gigManager.bookGig(
            gameState: &gameState,
            venue: venue,
            setlistID: setlistID,
            scheduledAt: scheduledAt,
            ticketPrice: ticketPrice
        )
        refreshTrigger += 1
    }
    
    var upcomingGigs: [Gig] {
        gameState.upcomingGigs
    }
    
    var completedGigs: [Gig] {
        gameState.completedGigs
    }
    
    func gig(for id: UUID) -> Gig? {
        gameState.gig(for: id)
    }
    
    // MARK: - Automatic Gig Execution
    
    private func checkScheduledGigs() {
        let now = Date()
        
        for gig in gameState.gigs where gig.status == .booked && gig.scheduledAt <= now {
            // Find the venue
            if let venue = Venue.venues.first(where: { $0.id == gig.venueID }) {
                try? gigManager.executeGig(
                    gameState: &gameState,
                    gigID: gig.id,
                    venue: venue
                )
            }
        }
    }
}
