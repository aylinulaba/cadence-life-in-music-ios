import Foundation

public struct GameState: Codable, Sendable {
    public var player: Player
    public var wallet: Wallet
    public var skills: [Skill]
    public var primaryFocus: TimeSlot
    public var freeTime: TimeSlot
    
    // Music Loop
    public var songs: [Song]
    public var setlists: [Setlist]
    public var recordings: [Recording]
    public var releases: [Release]
    public var gigs: [Gig]
    
    public init(
        player: Player,
        wallet: Wallet,
        skills: [Skill],
        primaryFocus: TimeSlot,
        freeTime: TimeSlot,
        songs: [Song] = [],
        setlists: [Setlist] = [],
        recordings: [Recording] = [],
        releases: [Release] = [],
        gigs: [Gig] = []
    ) {
        self.player = player
        self.wallet = wallet
        self.skills = skills
        self.primaryFocus = primaryFocus
        self.freeTime = freeTime
        self.songs = songs
        self.setlists = setlists
        self.recordings = recordings
        self.releases = releases
        self.gigs = gigs
    }
}

// MARK: - Factory Method
extension GameState {
    public static func new(player: Player) -> GameState {
        let wallet = Wallet(playerID: player.id)
        
        // Initialize basic skills at level 0
        let skills = Skill.SkillType.allCases.map { skillType in
            Skill(playerID: player.id, skillType: skillType)
        }
        
        let primaryFocus = TimeSlot(
            playerID: player.id,
            slotType: .primaryFocus
        )
        
        let freeTime = TimeSlot(
            playerID: player.id,
            slotType: .freeTime
        )
        
        return GameState(
            player: player,
            wallet: wallet,
            skills: skills,
            primaryFocus: primaryFocus,
            freeTime: freeTime
        )
    }
}

// MARK: - Skill Lookup
extension GameState {
    public func skill(for type: Skill.SkillType) -> Skill? {
        skills.first { $0.skillType == type }
    }
    
    public mutating func updateSkill(_ skill: Skill) {
        if let index = skills.firstIndex(where: { $0.id == skill.id }) {
            skills[index] = skill
        }
    }
}

// MARK: - Song Management
extension GameState {
    public mutating func addSong(_ song: Song) {
        songs.append(song)
    }
    
    public mutating func updateSong(_ song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index] = song
        }
    }
    
    public func song(for id: UUID) -> Song? {
        songs.first { $0.id == id }
    }
    
    public var unreleasedSongs: [Song] {
        songs.filter { !$0.isReleased }
    }
}

// MARK: - Setlist Management
extension GameState {
    public mutating func addSetlist(_ setlist: Setlist) {
        setlists.append(setlist)
    }
    
    public mutating func updateSetlist(_ setlist: Setlist) {
        if let index = setlists.firstIndex(where: { $0.id == setlist.id }) {
            setlists[index] = setlist
        }
    }
    
    public func setlist(for id: UUID) -> Setlist? {
        setlists.first { $0.id == id }
    }
}

// MARK: - Recording Management
extension GameState {
    public mutating func addRecording(_ recording: Recording) {
        recordings.append(recording)
    }
    
    public mutating func updateRecording(_ recording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
        }
    }
    
    public func recording(for id: UUID) -> Recording? {
        recordings.first { $0.id == id }
    }
    
    public var unreleasedRecordings: [Recording] {
        recordings.filter { !$0.isReleased }
    }
}

// MARK: - Release Management
extension GameState {
    public mutating func addRelease(_ release: Release) {
        releases.append(release)
    }
    
    public mutating func updateRelease(_ release: Release) {
        if let index = releases.firstIndex(where: { $0.id == release.id }) {
            releases[index] = release
        }
    }
    
    public func release(for id: UUID) -> Release? {
        releases.first { $0.id == id }
    }
}

// MARK: - Gig Management
extension GameState {
    public mutating func addGig(_ gig: Gig) {
        gigs.append(gig)
    }
    
    public mutating func updateGig(_ gig: Gig) {
        if let index = gigs.firstIndex(where: { $0.id == gig.id }) {
            gigs[index] = gig
        }
    }
    
    public func gig(for id: UUID) -> Gig? {
        gigs.first { $0.id == id }
    }
    
    public var upcomingGigs: [Gig] {
        gigs.filter { $0.status == .booked && $0.scheduledAt > Date() }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }
    
    public var completedGigs: [Gig] {
        gigs.filter { $0.status == .completed }
            .sorted { $0.scheduledAt > $1.scheduledAt }
    }
}
