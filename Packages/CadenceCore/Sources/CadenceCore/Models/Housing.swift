import Foundation

/// Represents a player's housing
public struct Housing: Identifiable, Codable, Sendable {
    public let id: UUID
    public var playerID: UUID
    public var housingType: HousingType
    public var cityID: UUID
    public var rentedAt: Date
    public var lastRentPayment: Date
    public var rentPaidUntil: Date
    
    public init(
        id: UUID = UUID(),
        playerID: UUID,
        housingType: HousingType,
        cityID: UUID,
        rentedAt: Date = Date(),
        lastRentPayment: Date = Date(),
        rentPaidUntil: Date = Date().addingTimeInterval(7 * 24 * 3600) // 1 week from now
    ) {
        self.id = id
        self.playerID = playerID
        self.housingType = housingType
        self.cityID = cityID
        self.rentedAt = rentedAt
        self.lastRentPayment = lastRentPayment
        self.rentPaidUntil = rentPaidUntil
    }
    
    // MARK: - Housing Type
    
    public enum HousingType: String, Codable, CaseIterable, Sendable {
        case studio
        case oneBedroom
        case twoBedroom
        case penthouse
        
        public var displayName: String {
            switch self {
            case .studio: return "Studio Apartment"
            case .oneBedroom: return "One Bedroom"
            case .twoBedroom: return "Two Bedroom"
            case .penthouse: return "Penthouse"
            }
        }
        
        public var emoji: String {
            switch self {
            case .studio: return "🏠"
            case .oneBedroom: return "🏡"
            case .twoBedroom: return "🏘️"
            case .penthouse: return "🏰"
            }
        }
        
        public var description: String {
            switch self {
            case .studio:
                return "A cozy studio with basic amenities. Perfect for starting musicians."
            case .oneBedroom:
                return "More space and comfort. Good for focused work and rest."
            case .twoBedroom:
                return "Spacious living with a dedicated music room. Great for creativity."
            case .penthouse:
                return "Luxury living with stunning views and premium amenities."
            }
        }
        
        /// Base weekly rent (before city multiplier)
        public var baseWeeklyRent: Decimal {
            switch self {
            case .studio: return 200
            case .oneBedroom: return 400
            case .twoBedroom: return 700
            case .penthouse: return 1500
            }
        }
        
        /// Equipment storage slots
        public var storageSlots: Int {
            switch self {
            case .studio: return 5
            case .oneBedroom: return 10
            case .twoBedroom: return 20
            case .penthouse: return 50
            }
        }
        
        /// Rest quality multiplier (affects health/mood recovery)
        public var restQualityMultiplier: Double {
            switch self {
            case .studio: return 1.0      // Normal recovery
            case .oneBedroom: return 1.2  // 20% faster
            case .twoBedroom: return 1.4  // 40% faster
            case .penthouse: return 1.8   // 80% faster
            }
        }
        
        /// Reputation bonus from living here
        public var reputationBonus: Int {
            switch self {
            case .studio: return 0
            case .oneBedroom: return 5
            case .twoBedroom: return 10
            case .penthouse: return 25
            }
        }
        
        /// Whether this housing allows home recording
        public var allowsHomeRecording: Bool {
            switch self {
            case .studio: return false
            case .oneBedroom: return false
            case .twoBedroom: return true   // Has dedicated music room
            case .penthouse: return true    // Has premium home studio
            }
        }
        
        /// Home recording quality cap (if allowed)
        public var homeRecordingQualityCap: Int {
            switch self {
            case .studio: return 0
            case .oneBedroom: return 0
            case .twoBedroom: return 60     // Basic home setup
            case .penthouse: return 85      // Professional home studio
            }
        }
        
        /// Passive mood gain per day
        public var passiveMoodBonus: Int {
            switch self {
            case .studio: return 0
            case .oneBedroom: return 1
            case .twoBedroom: return 2
            case .penthouse: return 5
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Weekly rent for this housing in this city
    public func weeklyRent(in city: City) -> Decimal {
        housingType.baseWeeklyRent * city.housingCostMultiplier
    }
    
    /// Days until next rent payment
    public var daysUntilRentDue: Int {
        let now = Date()
        let interval = rentPaidUntil.timeIntervalSince(now)
        return max(0, Int(interval / (24 * 3600)))
    }
    
    /// Whether rent is overdue
    public var isRentOverdue: Bool {
        Date() > rentPaidUntil
    }
    
    /// Whether rent is due soon (within 2 days)
    public var isRentDueSoon: Bool {
        daysUntilRentDue <= 2
    }
    
    /// Days overdue (if rent is late)
    public var daysOverdue: Int {
        guard isRentOverdue else { return 0 }
        let interval = Date().timeIntervalSince(rentPaidUntil)
        return Int(interval / (24 * 3600))
    }
    
    /// Whether player is at risk of eviction (7+ days overdue)
    public var isAtRiskOfEviction: Bool {
        daysOverdue >= 7
    }
    
    // MARK: - Methods
    
    /// Pay rent and extend the paid-until date
    public mutating func payRent(weeksCount: Int = 1) {
        let secondsPerWeek: TimeInterval = 7 * 24 * 3600
        
        if isRentOverdue {
            // If overdue, extend from now
            rentPaidUntil = Date().addingTimeInterval(secondsPerWeek * Double(weeksCount))
        } else {
            // If not overdue, extend from current paid-until date
            rentPaidUntil = rentPaidUntil.addingTimeInterval(secondsPerWeek * Double(weeksCount))
        }
        
        lastRentPayment = Date()
    }
}

// MARK: - City Housing Costs

extension City {
    /// Housing cost multiplier for this city
    public var housingCostMultiplier: Decimal {
        switch self.name {
        case "Los Angeles": return 1.5      // Very expensive
        case "New York": return 1.6         // Most expensive
        case "London": return 1.4           // Expensive
        case "Istanbul": return 0.7         // Affordable
        case "Tokyo": return 1.3            // Expensive
        default: return 1.0                 // Default
        }
    }
}

// MARK: - Housing Catalog

extension Housing {
    /// All available housing types with details
    public static let catalog: [HousingCatalogItem] = HousingType.allCases.map { type in
        HousingCatalogItem(housingType: type)
    }
    
    /// Get catalog filtered by affordability
    public static func affordableCatalog(
        maxWeeklyRent: Decimal,
        in city: City
    ) -> [HousingCatalogItem] {
        catalog.filter { item in
            item.weeklyRent(in: city) <= maxWeeklyRent
        }
    }
}

// MARK: - Housing Catalog Item

/// Represents a housing option in the catalog
public struct HousingCatalogItem: Identifiable, Sendable {
    public let id: UUID
    public let housingType: Housing.HousingType
    
    public init(
        id: UUID = UUID(),
        housingType: Housing.HousingType
    ) {
        self.id = id
        self.housingType = housingType
    }
    
    /// Calculate weekly rent for this housing in a specific city
    public func weeklyRent(in city: City) -> Decimal {
        housingType.baseWeeklyRent * city.housingCostMultiplier
    }
    
    /// Create a housing instance from this catalog item
    public func createHousing(for playerID: UUID, in cityID: UUID) -> Housing {
        Housing(
            playerID: playerID,
            housingType: housingType,
            cityID: cityID
        )
    }
}
