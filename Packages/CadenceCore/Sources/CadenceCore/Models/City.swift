import Foundation

public struct City: Identifiable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let country: String
    public let musicFocus: [String]
    public let description: String
    public let emoji: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        country: String,
        musicFocus: [String],
        description: String,
        emoji: String
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.musicFocus = musicFocus
        self.description = description
        self.emoji = emoji
    }
}

// MARK: - Seed Data
extension City {
    public static let losAngeles = City(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Los Angeles",
        country: "USA",
        musicFocus: ["Pop", "Hip-Hop", "Film Music"],
        description: "Global entertainment hub",
        emoji: "🌴"
    )
    
    public static let newYork = City(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "New York",
        country: "USA",
        musicFocus: ["Jazz", "Indie", "Hip-Hop"],
        description: "Diverse cultural scene",
        emoji: "🗽"
    )
    
    public static let london = City(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "London",
        country: "UK",
        musicFocus: ["Rock", "Electronic", "Pop"],
        description: "Global music capital",
        emoji: "🎸"
    )
    
    public static let istanbul = City(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        name: "Istanbul",
        country: "Turkey",
        musicFocus: ["Pop", "Folk", "Fusion"],
        description: "Cultural bridge East-West",
        emoji: "🕌"
    )
    
    public static let tokyo = City(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        name: "Tokyo",
        country: "Japan",
        musicFocus: ["J-Pop", "Electronic", "Idol"],
        description: "Modern Asian hub",
        emoji: "🗼"
    )
    
    public static let allCities: [City] = [
        .losAngeles,
        .newYork,
        .london,
        .istanbul,
        .tokyo
    ]
}
