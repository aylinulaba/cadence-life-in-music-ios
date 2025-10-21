import Foundation
import Supabase
import CadenceCore

final class DatabaseService {
    static let shared = DatabaseService()
    
    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }
    
    private init() {
        print("DatabaseService initialized")
    }
    
    // MARK: - Test Connection
    
    func testConnection() async throws {
        print("Testing Supabase connection...")
        
        do {
            print("Sending request to database...")
            
            let response: [PlayerRow] = try await client
                .from("players")
                .select()
                .limit(1)
                .execute()
                .value
            
            print("Supabase connected!")
            print("Response: \(response.count) rows")
            
        } catch {
            print("Connection failed!")
            print("Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Player Operations
    
    func createPlayer(
        gameCenterID: String,
        name: String,
        gender: String,
        avatarID: String,
        currentCityID: UUID
    ) async throws -> UUID {
        print("Creating player in database...")
        
        struct PlayerInsert: Encodable {
            let game_center_id: String
            let name: String
            let gender: String
            let avatar_id: String
            let current_city_id: String
            let health: Int
            let mood: Int
            let fame: Int
            let reputation: Int
        }
        
        struct PlayerResponse: Decodable {
            let id: String
        }
        
        let insert = PlayerInsert(
            game_center_id: gameCenterID,
            name: name,
            gender: gender,
            avatar_id: avatarID,
            current_city_id: currentCityID.uuidString,
            health: 80,
            mood: 70,
            fame: 0,
            reputation: 50
        )
        
        let response: PlayerResponse = try await client
            .from("players")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value
        
        guard let uuid = UUID(uuidString: response.id) else {
            throw DatabaseError.invalidUUID
        }
        
        print("Player created with ID: \(uuid)")
        return uuid
    }
    
    func createWallet(playerID: UUID) async throws {
        print("Creating wallet for player...")
        
        struct WalletInsert: Encodable {
            let player_id: String
            let balance: Double
            let lifetime_earnings: Double
            let lifetime_spending: Double
        }
        
        let insert = WalletInsert(
            player_id: playerID.uuidString,
            balance: 500.0,
            lifetime_earnings: 500.0,
            lifetime_spending: 0.0
        )
        
        try await client
            .from("wallets")
            .insert(insert)
            .execute()
        
        print("Wallet created")
    }
    
    func createSkill(playerID: UUID, skillType: String) async throws {
        print("Creating skill: \(skillType)...")
        
        struct SkillInsert: Encodable {
            let player_id: String
            let skill_type: String
            let current_xp: Int
            let current_level: Int
        }
        
        let insert = SkillInsert(
            player_id: playerID.uuidString,
            skill_type: skillType,
            current_xp: 0,
            current_level: 0
        )
        
        try await client
            .from("skills")
            .insert(insert)
            .execute()
        
        print("Skill created: \(skillType)")
    }
    
    func fetchPlayer(gameCenterID: String) async throws -> UUID? {
        print("Fetching player by Game Center ID: \(gameCenterID)")
        
        struct PlayerResponse: Decodable {
            let id: String
        }
        
        let response: [PlayerResponse] = try await client
            .from("players")
            .select()
            .eq("game_center_id", value: gameCenterID)
            .execute()
            .value
        
        guard let first = response.first,
              let uuid = UUID(uuidString: first.id) else {
            return nil
        }
        
        print("Found player: \(uuid)")
        return uuid
    }
    
    // MARK: - Fetch Player Data
    
    func fetchPlayerData(playerID: UUID) async throws -> Player {
        print("Fetching player data...")
        
        struct PlayerRow: Decodable {
            let id: String
            let game_center_id: String
            let name: String
            let gender: String
            let avatar_id: String
            let current_city_id: String?
            let health: Int
            let mood: Int
            let fame: Int
            let reputation: Int
        }
        
        let row: PlayerRow = try await client
            .from("players")
            .select()
            .eq("id", value: playerID.uuidString)
            .single()
            .execute()
            .value
        
        // Convert current_city_id string to UUID
        let cityID: UUID
        if let cityString = row.current_city_id,
           let parsedCityID = UUID(uuidString: cityString) {
            cityID = parsedCityID
        } else {
            // Default to Los Angeles if no city stored
            cityID = City.losAngeles.id
        }

        return Player(
            id: UUID(uuidString: row.id)!,
            name: row.name,
            gender: Player.Gender(rawValue: row.gender) ?? .nonBinary,
            avatarID: row.avatar_id,
            currentCityID: cityID,
            health: row.health,
            mood: row.mood,
            fame: row.fame,
            reputation: row.reputation
        )
    }
    
    func fetchWallet(playerID: UUID) async throws -> Wallet {
        print("Fetching wallet...")
        
        struct WalletRow: Decodable {
            let id: String
            let player_id: String
            let balance: Double
            let lifetime_earnings: Double
            let lifetime_spending: Double
        }
        
        let row: WalletRow = try await client
            .from("wallets")
            .select()
            .eq("player_id", value: playerID.uuidString)
            .single()
            .execute()
            .value
        
        return Wallet(
            id: UUID(uuidString: row.id)!,
            playerID: UUID(uuidString: row.player_id)!,
            balance: Decimal(row.balance),
            lifetimeEarnings: Decimal(row.lifetime_earnings),
            lifetimeSpending: Decimal(row.lifetime_spending)
        )
    }
    
    func fetchSkills(playerID: UUID) async throws -> [Skill] {
        print("Fetching skills...")
        
        struct SkillRow: Decodable {
            let id: String
            let player_id: String
            let skill_type: String
            let current_xp: Int
            let current_level: Int
        }
        
        let rows: [SkillRow] = try await client
            .from("skills")
            .select()
            .eq("player_id", value: playerID.uuidString)
            .execute()
            .value
        
        return rows.compactMap { row in
            guard let skillID = UUID(uuidString: row.id),
                  let playerUUID = UUID(uuidString: row.player_id),
                  let skillType = Skill.SkillType(rawValue: row.skill_type) else {
                return nil
            }
            
            return Skill(
                id: skillID,
                playerID: playerUUID,
                skillType: skillType,
                currentXP: row.current_xp,
                currentLevel: row.current_level
            )
        }
    }
    
    func fetchTimeSlots(playerID: UUID) async throws -> [TimeSlot] {
        print("Fetching time slots...")
        
        return [
            TimeSlot(playerID: playerID, slotType: .primaryFocus),
            TimeSlot(playerID: playerID, slotType: .freeTime)
        ]
    }
    
    func fetchSongs(playerID: UUID) async throws -> [Song] {
        print("Fetching songs...")
        return []
    }
    
    func fetchSetlists(playerID: UUID) async throws -> [Setlist] {
        print("Fetching setlists...")
        return []
    }
    
    func fetchRecordings(playerID: UUID) async throws -> [Recording] {
        print("Fetching recordings...")
        return []
    }
    
    func fetchReleases(playerID: UUID) async throws -> [Release] {
        print("Fetching releases...")
        return []
    }
    
    func fetchGigs(playerID: UUID) async throws -> [Gig] {
        print("Fetching gigs...")
        return []
    }
}

// MARK: - Supporting Types

struct PlayerRow: Decodable {
    let id: String
    let game_center_id: String
    let name: String
}

enum DatabaseError: Error {
    case invalidUUID
    case notFound
    case invalidData
}
