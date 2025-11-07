import Foundation

/// Manages housing rentals, rent payments, and upgrades
public final class HousingManager: Sendable {
    
    public init() {}
    
    // MARK: - Rent Housing
    
    /// Rent a new housing unit
    public func rentHousing(
        gameState: inout GameState,
        housingType: Housing.HousingType,
        cityID: UUID
    ) throws {
        // Get the city
        guard let city = City.allCities.first(where: { $0.id == cityID }) else {
            throw HousingError.cityNotFound
        }
        
        // Calculate first week's rent
        let firstWeekRent = housingType.baseWeeklyRent * city.housingCostMultiplier
        
        // Check if player can afford it
        guard gameState.wallet.balance >= firstWeekRent else {
            throw HousingError.insufficientFunds
        }
        
        // Deduct first week's rent
        try gameState.wallet.deductExpense(firstWeekRent)
        
        // Create housing
        let housing = Housing(
            playerID: gameState.player.id,
            housingType: housingType,
            cityID: cityID
        )
        
        // Set as current housing
        gameState.currentHousing = housing
        
        // Apply reputation bonus if moving up
        gameState.player.reputation += housingType.reputationBonus
    }
    
    // MARK: - Upgrade Housing
    
    /// Upgrade to a better housing type
    public func upgradeHousing(
        gameState: inout GameState,
        newHousingType: Housing.HousingType
    ) throws {
        guard var currentHousing = gameState.currentHousing else {
            throw HousingError.noCurrentHousing
        }
        
        // Check if this is actually an upgrade
        let currentIndex = Housing.HousingType.allCases.firstIndex(of: currentHousing.housingType) ?? 0
        let newIndex = Housing.HousingType.allCases.firstIndex(of: newHousingType) ?? 0
        
        guard newIndex > currentIndex else {
            throw HousingError.notAnUpgrade
        }
        
        // Get the city
        guard let city = City.allCities.first(where: { $0.id == currentHousing.cityID }) else {
            throw HousingError.cityNotFound
        }
        
        // Calculate rent difference for remaining period
        let oldWeeklyRent = currentHousing.housingType.baseWeeklyRent * city.housingCostMultiplier
        let newWeeklyRent = newHousingType.baseWeeklyRent * city.housingCostMultiplier
        let rentDifference = newWeeklyRent - oldWeeklyRent
        
        // Calculate prorated cost based on days left
        let daysLeft = currentHousing.daysUntilRentDue
        let proratedCost = (rentDifference / 7) * Decimal(daysLeft)
        
        // Check if player can afford upgrade
        guard gameState.wallet.balance >= proratedCost else {
            throw HousingError.insufficientFunds
        }
        
        // Deduct prorated cost
        try gameState.wallet.deductExpense(proratedCost)
        
        // Remove old reputation bonus
        gameState.player.reputation -= currentHousing.housingType.reputationBonus
        
        // Upgrade housing
        currentHousing.housingType = newHousingType
        gameState.currentHousing = currentHousing
        
        // Add new reputation bonus
        gameState.player.reputation += newHousingType.reputationBonus
    }
    
    // MARK: - Downgrade Housing
    
    /// Downgrade to a cheaper housing type
    public func downgradeHousing(
        gameState: inout GameState,
        newHousingType: Housing.HousingType
    ) throws {
        guard var currentHousing = gameState.currentHousing else {
            throw HousingError.noCurrentHousing
        }
        
        // Check if this is actually a downgrade
        let currentIndex = Housing.HousingType.allCases.firstIndex(of: currentHousing.housingType) ?? 0
        let newIndex = Housing.HousingType.allCases.firstIndex(of: newHousingType) ?? 0
        
        guard newIndex < currentIndex else {
            throw HousingError.notADowngrade
        }
        
        // Get the city
        guard let city = City.allCities.first(where: { $0.id == currentHousing.cityID }) else {
            throw HousingError.cityNotFound
        }
        
        // Calculate rent credit for remaining period
        let oldWeeklyRent = currentHousing.housingType.baseWeeklyRent * city.housingCostMultiplier
        let newWeeklyRent = newHousingType.baseWeeklyRent * city.housingCostMultiplier
        let rentDifference = oldWeeklyRent - newWeeklyRent
        
        // Calculate prorated credit based on days left
        let daysLeft = currentHousing.daysUntilRentDue
        let proratedCredit = (rentDifference / 7) * Decimal(daysLeft)
        
        // Refund prorated credit
        gameState.wallet.addIncome(proratedCredit)
        
        // Remove old reputation bonus
        gameState.player.reputation -= currentHousing.housingType.reputationBonus
        
        // Downgrade housing
        currentHousing.housingType = newHousingType
        gameState.currentHousing = currentHousing
        
        // Add new reputation bonus (lower)
        gameState.player.reputation += newHousingType.reputationBonus
    }
    
    // MARK: - Pay Rent
    
    /// Pay rent for current housing
    public func payRent(
        gameState: inout GameState,
        weeksCount: Int = 1
    ) throws {
        guard var housing = gameState.currentHousing else {
            throw HousingError.noCurrentHousing
        }
        
        // Get the city
        guard let city = City.allCities.first(where: { $0.id == housing.cityID }) else {
            throw HousingError.cityNotFound
        }
        
        // Calculate total rent
        let weeklyRent = housing.weeklyRent(in: city)
        let totalRent = weeklyRent * Decimal(weeksCount)
        
        // Check if player can afford it
        guard gameState.wallet.balance >= totalRent else {
            throw HousingError.insufficientFunds
        }
        
        // Deduct rent
        try gameState.wallet.deductExpense(totalRent)
        
        // Update housing
        housing.payRent(weeksCount: weeksCount)
        gameState.currentHousing = housing
    }
    
    // MARK: - Process Automatic Rent
    
    /// Process automatic rent payments (called periodically)
    public func processAutomaticRent(gameState: inout GameState) {
        guard var housing = gameState.currentHousing else { return }
        
        // Only process if rent is due
        guard housing.isRentOverdue else { return }
        
        // Get the city
        guard let city = City.allCities.first(where: { $0.id == housing.cityID }) else { return }
        
        // Calculate weekly rent
        let weeklyRent = housing.weeklyRent(in: city)
        
        // Try to pay automatically
        if gameState.wallet.balance >= weeklyRent {
            do {
                try gameState.wallet.deductExpense(weeklyRent)
                housing.payRent(weeksCount: 1)
                gameState.currentHousing = housing
                print("✅ Automatic rent payment successful")
            } catch {
                print("⚠️ Automatic rent payment failed: \(error)")
            }
        } else {
            print("⚠️ Insufficient funds for automatic rent payment")
            
            // Check for eviction
            if housing.isAtRiskOfEviction {
                // Downgrade to studio or evict
                if housing.housingType != .studio {
                    housing.housingType = .studio
                    housing.payRent(weeksCount: 1) // Reset rent period
                    gameState.currentHousing = housing
                    print("⚠️ Downgraded to Studio due to missed rent payments")
                }
            }
        }
    }
    
    // MARK: - Housing Benefits
    
    /// Get rest quality multiplier from current housing
    public func getRestQualityMultiplier(gameState: GameState) -> Double {
        guard let housing = gameState.currentHousing else { return 1.0 }
        return housing.housingType.restQualityMultiplier
    }
    
    /// Check if player can record at home
    public func canRecordAtHome(gameState: GameState) -> Bool {
        guard let housing = gameState.currentHousing else { return false }
        return housing.housingType.allowsHomeRecording
    }
    
    /// Get home recording quality cap
    public func getHomeRecordingQualityCap(gameState: GameState) -> Int {
        guard let housing = gameState.currentHousing else { return 0 }
        return housing.housingType.homeRecordingQualityCap
    }
    
    /// Get storage slots from current housing
    public func getStorageSlots(gameState: GameState) -> Int {
        guard let housing = gameState.currentHousing else { return 5 }
        return housing.housingType.storageSlots
    }
    
    /// Apply passive mood bonus from housing (call daily)
    public func applyPassiveMoodBonus(gameState: inout GameState) {
        guard let housing = gameState.currentHousing else { return }
        let bonus = housing.housingType.passiveMoodBonus
        if bonus > 0 {
            gameState.player.adjustMood(by: bonus)
        }
    }
    
    // MARK: - Housing Warnings
    
    /// Check if player should be warned about rent
    public func shouldWarnAboutRent(gameState: GameState) -> Bool {
        guard let housing = gameState.currentHousing else { return false }
        return housing.isRentDueSoon || housing.isRentOverdue
    }
    
    /// Get rent warning message
    public func getRentWarningMessage(gameState: GameState) -> String? {
        guard let housing = gameState.currentHousing,
              let city = City.allCities.first(where: { $0.id == housing.cityID }) else {
            return nil
        }
        
        if housing.isAtRiskOfEviction {
            return "🚨 EVICTION WARNING: \(housing.daysOverdue) days overdue! Pay rent immediately or you'll be downgraded."
        } else if housing.isRentOverdue {
            return "⚠️ Rent is \(housing.daysOverdue) day\(housing.daysOverdue == 1 ? "" : "s") overdue. Pay $\(housing.weeklyRent(in: city)) to avoid penalties."
        } else if housing.isRentDueSoon {
            return "💡 Rent due in \(housing.daysUntilRentDue) day\(housing.daysUntilRentDue == 1 ? "" : "s"). Prepare $\(housing.weeklyRent(in: city))."
        }
        
        return nil
    }
}

// MARK: - Housing Errors

public enum HousingError: Error, LocalizedError {
    case noCurrentHousing
    case cityNotFound
    case insufficientFunds
    case notAnUpgrade
    case notADowngrade
    case storageExceeded
    
    public var errorDescription: String? {
        switch self {
        case .noCurrentHousing:
            return "You don't have any housing yet"
        case .cityNotFound:
            return "City not found"
        case .insufficientFunds:
            return "Not enough money for this housing"
        case .notAnUpgrade:
            return "This is not an upgrade"
        case .notADowngrade:
            return "This is not a downgrade"
        case .storageExceeded:
            return "Not enough storage space in this housing"
        }
    }
}
