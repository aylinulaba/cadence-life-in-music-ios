import Foundation

public struct GameState: Sendable {
    public var player: Player
    public var wallet: Wallet
    public var skills: [Skill]
    public var primaryFocus: TimeSlot
    public var freeTime: TimeSlot
    public var songs: [Song]
    public var setlists: [Setlist]
    public var recordings: [Recording]
    public var releases: [Release]
    public var gigs: [Gig]
    
    // Job payment tracking
    public var jobPayments: [JobPayment]
    public var lastJobStartDate: Date?
    
    // NEW: Equipment inventory
    public var equipmentInventory: [Equipment]
    
    public init(
        player: Player,
        wallet: Wallet,
        skills: [Skill],
        primaryFocus: TimeSlot,
        freeTime: TimeSlot,
        songs: [Song],
        setlists: [Setlist],
        recordings: [Recording],
        releases: [Release],
        gigs: [Gig],
        jobPayments: [JobPayment],
        lastJobStartDate: Date?,
        equipmentInventory: [Equipment]
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
        self.jobPayments = jobPayments
        self.lastJobStartDate = lastJobStartDate
        self.equipmentInventory = equipmentInventory
    }
    
    // MARK: - Job Payment Computed Properties
    
    /// All pending payments that haven't been processed yet
    public var pendingPayments: [JobPayment] {
        jobPayments.filter { $0.isPending }
    }
    
    /// All payments that are due to be processed now
    public var duePayments: [JobPayment] {
        jobPayments.filter { $0.isDue }
    }
    
    /// All payments that have already been processed
    public var paidPayments: [JobPayment] {
        jobPayments.filter { $0.isPaid }
    }
    
    /// The current job type if player is employed, nil otherwise
    public var currentJob: Activity.JobType? {
        if case .job(let jobType) = primaryFocus.currentActivity {
            return jobType
        }
        return nil
    }
    
    /// The date of the next scheduled payment
    public var nextPaymentDate: Date? {
        pendingPayments
            .map { $0.scheduledDate }
            .min()
    }
    
    // MARK: - Job Payment Methods
    
    /// Add a new job payment to the list
    public mutating func addJobPayment(_ payment: JobPayment) {
        jobPayments.append(payment)
    }
    
    /// Mark a payment as paid with the given date
    public mutating func markPaymentAsPaid(_ paymentID: UUID, paidDate: Date = Date()) {
        if let index = jobPayments.firstIndex(where: { $0.id == paymentID }) {
            jobPayments[index].status = .paid
            jobPayments[index].paidDate = paidDate
        }
    }
    
    // MARK: - Equipment Helpers (NEW)
    
    /// Get equipment by ID
    public func equipment(for id: UUID) -> Equipment? {
        equipmentInventory.first { $0.id == id }
    }
    
    /// Get all usable equipment
    public var usableEquipment: [Equipment] {
        equipmentInventory.filter { $0.isUsable }
    }
    
    /// Get equipment by type
    public func equipment(ofType type: Equipment.EquipmentType) -> [Equipment] {
        equipmentInventory.filter { $0.equipmentType == type }
    }
    
    /// Get best equipment for a skill type
    public func bestEquipment(for skillType: Skill.SkillType) -> Equipment? {
        equipmentInventory
            .filter { $0.equipmentType.relatedSkill == skillType && $0.isUsable }
            .max { $0.performanceBonus < $1.performanceBonus }
    }
    
    /// Add equipment to inventory
    public mutating func addEquipment(_ equipment: Equipment) {
        equipmentInventory.append(equipment)
    }
    
    /// Update existing equipment
    public mutating func updateEquipment(_ updatedEquipment: Equipment) {
        if let index = equipmentInventory.firstIndex(where: { $0.id == updatedEquipment.id }) {
            equipmentInventory[index] = updatedEquipment
        }
    }
    
    /// Remove equipment from inventory
    public mutating func removeEquipment(_ equipmentID: UUID) {
        equipmentInventory.removeAll { $0.id == equipmentID }
    }
    
    // MARK: - Skill Helpers
    
    public func skill(for type: Skill.SkillType) -> Skill? {
        skills.first { $0.skillType == type }
    }
    
    public mutating func updateSkill(_ updatedSkill: Skill) {
        if let index = skills.firstIndex(where: { $0.id == updatedSkill.id }) {
            skills[index] = updatedSkill
        }
    }
    
    // MARK: - Song Helpers
    
    public func song(for id: UUID) -> Song? {
        songs.first { $0.id == id }
    }
    
    public var unreleasedSongs: [Song] {
        songs.filter { !$0.isReleased }
    }
    
    /// Add a new song to the collection
    public mutating func addSong(_ song: Song) {
        songs.append(song)
    }
    
    /// Update an existing song
    public mutating func updateSong(_ updatedSong: Song) {
        if let index = songs.firstIndex(where: { $0.id == updatedSong.id }) {
            songs[index] = updatedSong
        }
    }
    
    // MARK: - Setlist Helpers
    
    public func setlist(for id: UUID) -> Setlist? {
        setlists.first { $0.id == id }
    }
    
    /// Add a new setlist to the collection
    public mutating func addSetlist(_ setlist: Setlist) {
        setlists.append(setlist)
    }
    
    /// Update an existing setlist
    public mutating func updateSetlist(_ updatedSetlist: Setlist) {
        if let index = setlists.firstIndex(where: { $0.id == updatedSetlist.id }) {
            setlists[index] = updatedSetlist
        }
    }
    
    // MARK: - Recording Helpers
    
    public func recording(for id: UUID) -> Recording? {
        recordings.first { $0.id == id }
    }
    
    public var unreleasedRecordings: [Recording] {
        recordings.filter { !$0.isReleased }
    }
    
    /// Add a new recording to the collection
    public mutating func addRecording(_ recording: Recording) {
        recordings.append(recording)
    }
    
    /// Update an existing recording
    public mutating func updateRecording(_ updatedRecording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == updatedRecording.id }) {
            recordings[index] = updatedRecording
        }
    }
    
    // MARK: - Release Helpers
    
    public func release(for id: UUID) -> Release? {
        releases.first { $0.id == id }
    }
    
    /// Add a new release to the collection
    public mutating func addRelease(_ release: Release) {
        releases.append(release)
    }
    
    /// Update an existing release
    public mutating func updateRelease(_ updatedRelease: Release) {
        if let index = releases.firstIndex(where: { $0.id == updatedRelease.id }) {
            releases[index] = updatedRelease
        }
    }
    
    // MARK: - Gig Helpers
    
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
    
    /// Add a new gig to the collection
    public mutating func addGig(_ gig: Gig) {
        gigs.append(gig)
    }
    
    /// Update an existing gig
    public mutating func updateGig(_ updatedGig: Gig) {
        if let index = gigs.firstIndex(where: { $0.id == updatedGig.id }) {
            gigs[index] = updatedGig
        }
    }
}

// MARK: - Factory Method

extension GameState {
    public static func new(player: Player) -> GameState {
        GameState(
            player: player,
            wallet: Wallet(playerID: player.id),
            skills: Skill.SkillType.allCases.map { Skill(playerID: player.id, skillType: $0) },
            primaryFocus: TimeSlot(playerID: player.id, slotType: .primaryFocus),
            freeTime: TimeSlot(playerID: player.id, slotType: .freeTime),
            songs: [],
            setlists: [],
            recordings: [],
            releases: [],
            gigs: [],
            jobPayments: [],
            lastJobStartDate: nil,
            equipmentInventory: []
        )
    }
}
