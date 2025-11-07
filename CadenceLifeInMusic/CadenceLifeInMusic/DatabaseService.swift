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
    
    // MARK: - Update Player Data (NEW)
    
    func updatePlayerHealth(playerID: UUID, health: Int) async throws {
        print("Updating player health...")
        
        struct HealthUpdate: Encodable {
            let health: Int
        }
        
        let update = HealthUpdate(health: health)
        
        try await client
            .from("players")
            .update(update)
            .eq("id", value: playerID.uuidString)
            .execute()
        
        print("Player health updated")
    }
    
    func updatePlayerMood(playerID: UUID, mood: Int) async throws {
        print("Updating player mood...")
        
        struct MoodUpdate: Encodable {
            let mood: Int
        }
        
        let update = MoodUpdate(mood: mood)
        
        try await client
            .from("players")
            .update(update)
            .eq("id", value: playerID.uuidString)
            .execute()
        
        print("Player mood updated")
    }
    
    func updatePlayerHealthAndMood(playerID: UUID, health: Int, mood: Int) async throws {
        print("Updating player health and mood...")
        
        struct HealthMoodUpdate: Encodable {
            let health: Int
            let mood: Int
        }
        
        let update = HealthMoodUpdate(health: health, mood: mood)
        
        try await client
            .from("players")
            .update(update)
            .eq("id", value: playerID.uuidString)
            .execute()
        
        print("Player health and mood updated")
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
    
    // MARK: - Job Payment Operations
    
    func fetchJobPayments(playerID: UUID) async throws -> [JobPayment] {
        print("Fetching job payments...")
        
        struct JobPaymentRow: Decodable {
            let id: String
            let player_id: String
            let job_type: String
            let amount: Double
            let scheduled_date: String
            let paid_date: String?
            let status: String
        }
        
        let rows: [JobPaymentRow] = try await client
            .from("job_payments")
            .select()
            .eq("player_id", value: playerID.uuidString)
            .execute()
            .value
        
        let dateFormatter = ISO8601DateFormatter()
        
        return rows.compactMap { row in
            guard let id = UUID(uuidString: row.id),
                  let playerUUID = UUID(uuidString: row.player_id),
                  let jobType = Activity.JobType(rawValue: row.job_type),
                  let scheduledDate = dateFormatter.date(from: row.scheduled_date),
                  let status = JobPayment.PaymentStatus(rawValue: row.status) else {
                return nil
            }
            
            let paidDate = row.paid_date.flatMap { dateFormatter.date(from: $0) }
            
            return JobPayment(
                id: id,
                playerID: playerUUID,
                jobType: jobType,
                amount: Decimal(row.amount),
                scheduledDate: scheduledDate,
                paidDate: paidDate,
                status: status
            )
        }
    }
    
    func saveJobPayment(_ payment: JobPayment) async throws {
        print("Saving job payment...")
        
        struct JobPaymentInsert: Encodable {
            let id: String
            let player_id: String
            let job_type: String
            let amount: Double
            let scheduled_date: String
            let paid_date: String?
            let status: String
        }
        
        let dateFormatter = ISO8601DateFormatter()
        
        let insert = JobPaymentInsert(
            id: payment.id.uuidString,
            player_id: payment.playerID.uuidString,
            job_type: payment.jobType.rawValue,
            amount: NSDecimalNumber(decimal: payment.amount).doubleValue,
            scheduled_date: dateFormatter.string(from: payment.scheduledDate),
            paid_date: payment.paidDate.map { dateFormatter.string(from: $0) },
            status: payment.status.rawValue
        )
        
        try await client
            .from("job_payments")
            .upsert(insert)
            .execute()
        
        print("Job payment saved")
    }
    
    func updateJobPaymentStatus(paymentID: UUID, status: JobPayment.PaymentStatus, paidDate: Date?) async throws {
        print("Updating job payment status...")
        
        struct JobPaymentUpdate: Encodable {
            let status: String
            let paid_date: String?
        }
        
        let dateFormatter = ISO8601DateFormatter()
        
        let update = JobPaymentUpdate(
            status: status.rawValue,
            paid_date: paidDate.map { dateFormatter.string(from: $0) }
        )
        
        try await client
            .from("job_payments")
            .update(update)
            .eq("id", value: paymentID.uuidString)
            .execute()
        
        print("Job payment status updated")
    }
    
    // MARK: - Equipment Operations
    
    func fetchEquipment(playerID: UUID) async throws -> [Equipment] {
        print("Fetching equipment...")
        
        struct EquipmentRow: Decodable {
            let id: String
            let owner_id: String
            let equipment_type: String
            let tier: String
            let name: String
            let base_price: Double
            let durability: Int
            let purchased_at: String
        }
        
        let rows: [EquipmentRow] = try await client
            .from("equipment")
            .select()
            .eq("owner_id", value: playerID.uuidString)
            .execute()
            .value
        
        let dateFormatter = ISO8601DateFormatter()
        
        return rows.compactMap { row in
            guard let id = UUID(uuidString: row.id),
                  let ownerID = UUID(uuidString: row.owner_id),
                  let equipmentType = Equipment.EquipmentType(rawValue: row.equipment_type),
                  let tier = Equipment.EquipmentTier(rawValue: row.tier),
                  let purchasedAt = dateFormatter.date(from: row.purchased_at) else {
                return nil
            }
            
            return Equipment(
                id: id,
                equipmentType: equipmentType,
                tier: tier,
                name: row.name,
                basePrice: Decimal(row.base_price),
                durability: row.durability,
                purchasedAt: purchasedAt,
                ownerID: ownerID
            )
        }
    }
    
    func saveEquipment(_ equipment: Equipment) async throws {
        print("Saving equipment...")
        
        struct EquipmentInsert: Encodable {
            let id: String
            let owner_id: String
            let equipment_type: String
            let tier: String
            let name: String
            let base_price: Double
            let durability: Int
            let purchased_at: String
        }
        
        let dateFormatter = ISO8601DateFormatter()
        
        let insert = EquipmentInsert(
            id: equipment.id.uuidString,
            owner_id: equipment.ownerID.uuidString,
            equipment_type: equipment.equipmentType.rawValue,
            tier: equipment.tier.rawValue,
            name: equipment.name,
            base_price: NSDecimalNumber(decimal: equipment.basePrice).doubleValue,
            durability: equipment.durability,
            purchased_at: dateFormatter.string(from: equipment.purchasedAt)
        )
        
        try await client
            .from("equipment")
            .upsert(insert)
            .execute()
        
        print("Equipment saved")
    }
    
    func updateEquipmentDurability(equipmentID: UUID, durability: Int) async throws {
        print("Updating equipment durability...")
        
        struct EquipmentUpdate: Encodable {
            let durability: Int
        }
        
        let update = EquipmentUpdate(durability: durability)
        
        try await client
            .from("equipment")
            .update(update)
            .eq("id", value: equipmentID.uuidString)
            .execute()
        
        print("Equipment durability updated")
    }
    
    func deleteEquipment(equipmentID: UUID) async throws {
        print("Deleting equipment...")
        
        try await client
            .from("equipment")
            .delete()
            .eq("id", value: equipmentID.uuidString)
            .execute()
        
        print("Equipment deleted")
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
