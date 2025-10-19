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
    
    func testConnection() async throws {
        print("Testing Supabase connection...")
        // print("Client URL: \(client.supabaseURL)")
        
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
        print("Fetching player by Game Center ID...")
        
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
}

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
