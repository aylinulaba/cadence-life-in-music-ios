import Foundation

public final class GigManager: Sendable {
    
    private let healthMoodManager = HealthMoodManager()
    
    public init() {}
    
    /// Book a gig at a venue
    public func bookGig(
        gameState: inout GameState,
        venue: Venue,
        setlistID: UUID,
        scheduledAt: Date,
        ticketPrice: Decimal
    ) throws {
        // Check if player meets fame requirement
        guard gameState.player.fame >= venue.minFame else {
            throw GigError.insufficientFame(required: venue.minFame, current: gameState.player.fame)
        }
        
        // Check if setlist exists
        guard gameState.setlist(for: setlistID) != nil else {
            throw GigError.setlistNotFound
        }
        
        // Check if player can afford booking
        guard gameState.wallet.balance >= venue.bookingCost else {
            throw GigError.insufficientFunds
        }
        
        // Check scheduled time is in future
        guard scheduledAt > Date() else {
            throw GigError.invalidScheduledTime
        }
        
        // Deduct booking cost
        try gameState.wallet.deductExpense(venue.bookingCost)
        
        // Create gig
        let gig = Gig(
            venueID: venue.id,
            playerID: gameState.player.id,
            setlistID: setlistID,
            scheduledAt: scheduledAt,
            ticketPrice: ticketPrice,
            bookingCost: venue.bookingCost
        )
        
        gameState.addGig(gig)
    }
    
    /// Calculate gig attendance
    public func calculateAttendance(
        venue: Venue,
        playerFame: Int,
        fanBase: Int,
        ticketPrice: Decimal
    ) -> Int {
        // Base draw from fan base
        let baseDraw = 20 + (fanBase / 10)
        
        // Fame multiplier
        let fameMultiplier = 1.0 + (Double(playerFame) / 1000.0)
        
        // Price sensitivity (higher price = lower attendance)
        let maxPrice = Decimal(venue.venueType == .smallClub ? 20 : 50)
        let priceRatio = Double(truncating: ticketPrice as NSNumber) / Double(truncating: maxPrice as NSNumber)
        let priceSensitivity = 1.0 - (priceRatio * 0.3)
        
        // Calculate attendance
        let calculatedAttendance = Int(Double(baseDraw) * fameMultiplier * priceSensitivity)
        
        // Cap at venue capacity
        return min(venue.capacity, max(0, calculatedAttendance))
    }
    
    /// Calculate performance quality
    public func calculatePerformanceQuality(
        setlistQuality: Int,
        performanceSkill: Int,
        health: Int,
        mood: Int
    ) -> Int {
        // Base calculation
        // Setlist quality (50% weight)
        let setlistComponent = Double(setlistQuality) * 0.5
        
        // Performance skill (30% weight)
        let skillComponent = Double(performanceSkill) * 0.3
        
        // Health (10% weight)
        let healthComponent = Double(health) * 0.1
        
        // Mood (10% weight)
        let moodComponent = Double(mood) * 0.1
        
        let baseQuality = setlistComponent + skillComponent + healthComponent + moodComponent
        
        // NEW: Apply health/mood performance modifier
        let healthMoodModifier = healthMoodManager.getPerformanceQualityModifier(
            health: health,
            mood: mood
        )
        
        let finalQuality = baseQuality * healthMoodModifier
        
        return Int(max(0, min(100, finalQuality)))
    }
    
    /// Execute a gig (called when scheduled time arrives)
    public func executeGig(
        gameState: inout GameState,
        gigID: UUID,
        venue: Venue
    ) throws {
        guard var gig = gameState.gig(for: gigID) else {
            throw GigError.gigNotFound
        }
        
        guard let setlist = gameState.setlist(for: gig.setlistID) else {
            throw GigError.setlistNotFound
        }
        
        // Calculate attendance
        let fanBase = 0 // TODO: Implement fan base tracking
        let attendance = calculateAttendance(
            venue: venue,
            playerFame: gameState.player.fame,
            fanBase: fanBase,
            ticketPrice: gig.ticketPrice
        )
        
        // Calculate performance quality with health/mood impact
        let performanceSkill = gameState.skill(for: .performance)?.currentLevel ?? 0
        let performanceQuality = calculatePerformanceQuality(
            setlistQuality: setlist.quality,
            performanceSkill: performanceSkill,
            health: gameState.player.health,
            mood: gameState.player.mood
        )
        
        // Calculate revenue
        let grossRevenue = Decimal(attendance) * gig.ticketPrice
        let venueCut = grossRevenue * 0.3 // Venue takes 30%
        let netPayout = grossRevenue - venueCut
        
        // Calculate fans gained
        let fansGained = Int(Double(attendance) * (Double(performanceQuality) / 100.0) * 0.5)
        
        // Calculate fame gained
        let fameGained = Int(Double(performanceQuality) * 0.1)
        
        // Update gig results
        gig.attendance = attendance
        gig.performanceQuality = performanceQuality
        gig.grossRevenue = grossRevenue
        gig.netPayout = netPayout
        gig.fansGained = fansGained
        gig.fameGained = fameGained
        gig.status = .completed
        
        gameState.updateGig(gig)
        
        // Add payout to wallet
        gameState.wallet.addIncome(netPayout)
        
        // Add fame
        gameState.player.fame += fameGained
        
        // Grant performance XP
        if var skill = gameState.skill(for: .performance) {
            let xpGain = 10 + (performanceQuality / 5) // 10-30 XP based on quality
            skill.addXP(xpGain)
            gameState.updateSkill(skill)
        }
        
        // NEW: Apply health/mood changes from gig
        var updatedPlayer = gameState.player
        
        // Performing is physically demanding
        updatedPlayer.adjustHealth(by: -5)
        
        // Mood changes based on performance quality
        let moodChange = healthMoodManager.calculateSuccessfulGigMoodBoost(
            attendance: attendance,
            quality: performanceQuality
        )
        
        if performanceQuality >= 70 {
            // Great performance - big mood boost
            updatedPlayer.adjustMood(by: moodChange)
        } else if performanceQuality >= 50 {
            // Decent performance - small mood boost
            updatedPlayer.adjustMood(by: moodChange / 2)
        } else {
            // Poor performance - mood loss
            let expectedAttendance = venue.capacity / 2
            let moodLoss = healthMoodManager.calculateFailedGigMoodLoss(
                expectedAttendance: expectedAttendance,
                actualAttendance: attendance
            )
            updatedPlayer.adjustMood(by: -moodLoss)
        }
        
        gameState.player = updatedPlayer
    }
    
    public enum GigError: Error, LocalizedError {
        case insufficientFame(required: Int, current: Int)
        case setlistNotFound
        case insufficientFunds
        case invalidScheduledTime
        case gigNotFound
        
        public var errorDescription: String? {
            switch self {
            case .insufficientFame(let required, let current):
                return "Need \(required) fame, but only have \(current)"
            case .setlistNotFound:
                return "Setlist not found"
            case .insufficientFunds:
                return "Not enough money to book this venue"
            case .invalidScheduledTime:
                return "Gig must be scheduled in the future"
            case .gigNotFound:
                return "Gig not found"
            }
        }
    }
}
