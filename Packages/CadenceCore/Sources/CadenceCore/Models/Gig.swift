import Foundation

public struct Gig: Identifiable, Codable, Sendable {
    public let id: UUID
    public let venueID: UUID
    public let playerID: UUID
    public let setlistID: UUID
    public let scheduledAt: Date
    public var ticketPrice: Decimal
    public let bookingCost: Decimal
    public var status: GigStatus
    
    // Results (populated after performance)
    public var attendance: Int?
    public var performanceQuality: Int?
    public var grossRevenue: Decimal?
    public var netPayout: Decimal?
    public var fansGained: Int?
    public var fameGained: Int?
    
    public enum GigStatus: String, Codable, Sendable {
        case booked = "Booked"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        public var emoji: String {
            switch self {
            case .booked: return "📅"
            case .inProgress: return "🎤"
            case .completed: return "✅"
            case .cancelled: return "❌"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        venueID: UUID,
        playerID: UUID,
        setlistID: UUID,
        scheduledAt: Date,
        ticketPrice: Decimal,
        bookingCost: Decimal,
        status: GigStatus = .booked
    ) {
        self.id = id
        self.venueID = venueID
        self.playerID = playerID
        self.setlistID = setlistID
        self.scheduledAt = scheduledAt
        self.ticketPrice = ticketPrice
        self.bookingCost = bookingCost
        self.status = status
    }
}

// MARK: - Venue
public struct Venue: Identifiable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let cityID: UUID
    public let capacity: Int
    public let bookingCost: Decimal
    public let minFame: Int
    public let venueType: VenueType
    
    public enum VenueType: String, Codable, Sendable {
        case street = "Street Performance"
        case smallClub = "Small Club"
        case midClub = "Mid Club"
        case concertHall = "Concert Hall"
        case arena = "Arena"
        
        public var emoji: String {
            switch self {
            case .street: return "🛣️"
            case .smallClub: return "🎵"
            case .midClub: return "🎸"
            case .concertHall: return "🎭"
            case .arena: return "🏟️"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        cityID: UUID,
        capacity: Int,
        bookingCost: Decimal,
        minFame: Int,
        venueType: VenueType
    ) {
        self.id = id
        self.name = name
        self.cityID = cityID
        self.capacity = capacity
        self.bookingCost = bookingCost
        self.minFame = minFame
        self.venueType = venueType
    }
}

// MARK: - Seed Venues
extension Venue {
    public static let venues: [Venue] = [
        // Los Angeles
        Venue(
            name: "The Troubadour",
            cityID: City.losAngeles.id,
            capacity: 100,
            bookingCost: 50,
            minFame: 0,
            venueType: .smallClub
        ),
        // New York
        Venue(
            name: "Mercury Lounge",
            cityID: City.newYork.id,
            capacity: 80,
            bookingCost: 50,
            minFame: 0,
            venueType: .smallClub
        ),
        // London
        Venue(
            name: "The Garage",
            cityID: City.london.id,
            capacity: 120,
            bookingCost: 50,
            minFame: 0,
            venueType: .smallClub
        ),
        // Istanbul
        Venue(
            name: "Babylon",
            cityID: City.istanbul.id,
            capacity: 90,
            bookingCost: 50,
            minFame: 0,
            venueType: .smallClub
        ),
        // Tokyo
        Venue(
            name: "Club Quattro",
            cityID: City.tokyo.id,
            capacity: 110,
            bookingCost: 50,
            minFame: 0,
            venueType: .smallClub
        )
    ]
}
