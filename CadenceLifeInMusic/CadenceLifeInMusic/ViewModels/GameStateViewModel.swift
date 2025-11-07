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
    private let jobPaymentManager = JobPaymentManager()
    private let equipmentManager = EquipmentManager()
    private let healthMoodManager = HealthMoodManager()
    private let housingManager = HousingManager()
    
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
    
    // MARK: - Job Management
    
    func startJob(jobType: Activity.JobType) {
        // Set the activity in primary focus
        gameState.primaryFocus.currentActivity = .job(type: jobType)
        gameState.primaryFocus.startedAt = Date()
        
        // Initialize job payment schedule
        jobPaymentManager.startJob(
            gameState: &gameState,
            jobType: jobType
        )
        
        refreshTrigger += 1
    }
    
    func quitJob() {
        // Clear the primary focus activity
        gameState.primaryFocus.currentActivity = nil
        gameState.primaryFocus.startedAt = nil
        
        // Cancel pending payments
        jobPaymentManager.quitJob(gameState: &gameState)
        
        refreshTrigger += 1
    }
    
    // MARK: - Job Payment Info
    
    var nextPaymentDate: Date? {
        gameState.nextPaymentDate
    }
    
    var daysUntilNextPayment: Int? {
        jobPaymentManager.daysUntilNextPayment(gameState: gameState)
    }
    
    var hoursWorkedThisWeek: Double {
        jobPaymentManager.hoursWorkedThisWeek(gameState: gameState)
    }
    
    var totalEarningsFromCurrentJob: Decimal {
        jobPaymentManager.totalEarningsFromCurrentJob(gameState: gameState)
    }
    
    var upcomingPayments: [JobPayment] {
        gameState.pendingPayments.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    var paymentHistory: [JobPayment] {
        gameState.paidPayments.sorted { $0.paidDate! > $1.paidDate! }
    }
    
    // MARK: - Equipment Management
    
    /// Purchase equipment from the shop
    func purchaseEquipment(catalogItem: EquipmentCatalogItem) throws {
        try equipmentManager.purchaseEquipment(
            gameState: &gameState,
            catalogItem: catalogItem
        )
        refreshTrigger += 1
    }
    
    /// Repair equipment
    func repairEquipment(equipmentID: UUID) throws {
        try equipmentManager.repairEquipment(
            gameState: &gameState,
            equipmentID: equipmentID
        )
        refreshTrigger += 1
    }
    
    /// Sell equipment
    func sellEquipment(equipmentID: UUID) throws {
        try equipmentManager.sellEquipment(
            gameState: &gameState,
            equipmentID: equipmentID
        )
        refreshTrigger += 1
    }
    
    /// Get player's equipment inventory
    var equipmentInventory: [Equipment] {
        gameState.equipmentInventory.sorted { $0.purchasedAt > $1.purchasedAt }
    }
    
    /// Get usable equipment only
    var usableEquipment: [Equipment] {
        gameState.usableEquipment
    }
    
    /// Get equipment that needs repair
    var equipmentNeedingRepair: [Equipment] {
        equipmentManager.getEquipmentNeedingRepair(gameState: gameState)
    }
    
    /// Get total inventory value
    var totalInventoryValue: Decimal {
        equipmentManager.getTotalInventoryValue(gameState: gameState)
    }
    
    /// Get equipment for specific type
    func equipment(ofType type: Equipment.EquipmentType) -> [Equipment] {
        gameState.equipment(ofType: type)
    }
    
    /// Check if player owns equipment of type
    func ownsEquipment(ofType type: Equipment.EquipmentType) -> Bool {
        equipmentManager.ownsEquipment(gameState: gameState, ofType: type)
    }
    
    /// Get best equipment bonus for a skill
    func equipmentBonus(for skillType: Skill.SkillType) -> Double {
        equipmentManager.getBestEquipmentBonus(gameState: gameState, for: skillType)
    }
    
    // MARK: - Health & Mood Management
    
    /// Get health status
    var healthStatus: Player.HealthStatus {
        gameState.player.healthStatus
    }
    
    /// Get mood status
    var moodStatus: Player.MoodStatus {
        gameState.player.moodStatus
    }
    
    /// Check if player needs health warning
    var needsHealthWarning: Bool {
        healthMoodManager.shouldWarnLowHealth(health: gameState.player.health)
    }
    
    /// Check if player needs mood warning
    var needsMoodWarning: Bool {
        healthMoodManager.shouldWarnLowMood(mood: gameState.player.mood)
    }
    
    /// Get health warning message if applicable
    var healthWarningMessage: String? {
        healthMoodManager.getHealthWarningMessage(health: gameState.player.health)
    }
    
    /// Get mood warning message if applicable
    var moodWarningMessage: String? {
        healthMoodManager.getMoodWarningMessage(mood: gameState.player.mood)
    }
    
    /// Get recommended action based on health/mood
    var recommendedAction: String {
        healthMoodManager.getRecommendedAction(
            health: gameState.player.health,
            mood: gameState.player.mood
        )
    }
    
    /// Get XP multiplier based on current health/mood
    var xpMultiplier: Double {
        healthMoodManager.getXPMultiplier(
            health: gameState.player.health,
            mood: gameState.player.mood
        )
    }
    
    /// Manually trigger rest (for debugging/testing)
    func rest(hours: Double) {
        var player = gameState.player
        player.rest(hours: hours)
        gameState.player = player
        refreshTrigger += 1
    }
    
    // MARK: - Housing Management (NEW)
    
    /// Rent new housing
    func rentHousing(housingType: Housing.HousingType, cityID: UUID) throws {
        try housingManager.rentHousing(
            gameState: &gameState,
            housingType: housingType,
            cityID: cityID
        )
        refreshTrigger += 1
    }
    
    /// Upgrade current housing
    func upgradeHousing(newHousingType: Housing.HousingType) throws {
        try housingManager.upgradeHousing(
            gameState: &gameState,
            newHousingType: newHousingType
        )
        refreshTrigger += 1
    }
    
    /// Downgrade current housing
    func downgradeHousing(newHousingType: Housing.HousingType) throws {
        try housingManager.downgradeHousing(
            gameState: &gameState,
            newHousingType: newHousingType
        )
        refreshTrigger += 1
    }
    
    /// Pay rent
    func payRent(weeksCount: Int = 1) throws {
        try housingManager.payRent(
            gameState: &gameState,
            weeksCount: weeksCount
        )
        refreshTrigger += 1
    }
    
    /// Get current housing
    var currentHousing: Housing? {
        gameState.currentHousing
    }
    
    /// Get rest quality multiplier from housing
    var housingRestMultiplier: Double {
        housingManager.getRestQualityMultiplier(gameState: gameState)
    }
    
    /// Check if player can record at home
    var canRecordAtHome: Bool {
        housingManager.canRecordAtHome(gameState: gameState)
    }
    
    /// Get home recording quality cap
    var homeRecordingQualityCap: Int {
        housingManager.getHomeRecordingQualityCap(gameState: gameState)
    }
    
    /// Get storage slots from housing
    var storageSlots: Int {
        housingManager.getStorageSlots(gameState: gameState)
    }
    
    /// Check if should warn about rent
    var shouldWarnAboutRent: Bool {
        housingManager.shouldWarnAboutRent(gameState: gameState)
    }
    
    /// Get rent warning message
    var rentWarningMessage: String? {
        housingManager.getRentWarningMessage(gameState: gameState)
    }
    
    /// Get weekly rent amount
    var weeklyRent: Decimal? {
        gameState.weeklyRent
    }
    
    /// Check if rent is due soon
    var isRentDueSoon: Bool {
        gameState.isRentDueSoon
    }
    
    /// Check if rent is overdue
    var isRentOverdue: Bool {
        gameState.isRentOverdue
    }
    
    /// Check if at risk of eviction
    var isAtRiskOfEviction: Bool {
        gameState.isAtRiskOfEviction
    }
}
