import Foundation
import GameKit
import Supabase
import CadenceCore

final class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // MARK: - Game Center Authentication
    
    func authenticateWithGameCenter() async throws -> String {
        print("🎮 Authenticating with Game Center...")
        
        #if targetEnvironment(simulator)
        // DEVELOPMENT BYPASS: Use fake ID in simulator
        print("⚠️ Running in simulator - using fake Game Center ID")
        let fakeID = "simulator-test-player"
        print("✅ Simulator auth complete: \(fakeID)")
        return fakeID
        #else
        // PRODUCTION: Real Game Center auth on device
        return try await withCheckedThrowingContinuation { continuation in
            GKLocalPlayer.local.authenticateHandler = { viewController, error in
                if let error = error {
                    print("❌ Game Center auth failed: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                if viewController != nil {
                    print("⚠️ Game Center needs user interaction")
                    continuation.resume(throwing: AuthError.needsUserInteraction)
                    return
                }
                
                if GKLocalPlayer.local.isAuthenticated {
                    let playerID = GKLocalPlayer.local.gamePlayerID
                    print("✅ Game Center authenticated: \(playerID)")
                    continuation.resume(returning: playerID)
                } else {
                    print("❌ Game Center not authenticated")
                    continuation.resume(throwing: AuthError.notAuthenticated)
                }
            }
        }
        #endif
    }
    
    // MARK: - Player Lookup & Creation
    
    func findOrCreatePlayer(gameCenterID: String, defaultName: String) async throws -> UUID {
        print("🔍 Looking for existing player...")
        
        // Check if player exists
        if let existingPlayerID = try await DatabaseService.shared.fetchPlayer(gameCenterID: gameCenterID) {
            print("✅ Found existing player: \(existingPlayerID)")
            return existingPlayerID
        }
        
        // Create new player
        print("📝 Creating new player...")
        
        let playerID = try await DatabaseService.shared.createPlayer(
            gameCenterID: gameCenterID,
            name: defaultName,
            gender: "non-binary",
            avatarID: "default",
            currentCityID: City.losAngeles.id
        )
        
        // Create wallet
        try await DatabaseService.shared.createWallet(playerID: playerID)
        
        // Create initial skills
        let skillTypes = ["guitar", "piano", "drums", "bass", "songwriting", "performance", "production"]
        for skillType in skillTypes {
            try await DatabaseService.shared.createSkill(playerID: playerID, skillType: skillType)
        }
        
        print("✅ New player created with full setup")
        return playerID
    }
    
    // MARK: - Load Player Data
    
    func loadPlayerData(playerID: UUID) async throws -> GameState {
        print("📥 Loading player data from database...")
        
        // Fetch all data
        let player = try await DatabaseService.shared.fetchPlayerData(playerID: playerID)
        let wallet = try await DatabaseService.shared.fetchWallet(playerID: playerID)
        let skills = try await DatabaseService.shared.fetchSkills(playerID: playerID)
        let songs = try await DatabaseService.shared.fetchSongs(playerID: playerID)
        let setlists = try await DatabaseService.shared.fetchSetlists(playerID: playerID)
        let recordings = try await DatabaseService.shared.fetchRecordings(playerID: playerID)
        let releases = try await DatabaseService.shared.fetchReleases(playerID: playerID)
        let gigs = try await DatabaseService.shared.fetchGigs(playerID: playerID)
        
        // Create time slots
        let primaryFocus = TimeSlot(
            playerID: playerID,
            slotType: .primaryFocus,
            currentActivity: nil,
            startedAt: nil
        )
        
        let freeTime = TimeSlot(
            playerID: playerID,
            slotType: .freeTime,
            currentActivity: nil,
            startedAt: nil
        )
        
        // Create GameState
        var gameState = GameState.new(player: player)
        gameState.wallet = wallet
        gameState.skills = skills
        gameState.primaryFocus = primaryFocus
        gameState.freeTime = freeTime
        gameState.songs = songs
        gameState.setlists = setlists
        gameState.recordings = recordings
        gameState.releases = releases
        gameState.gigs = gigs
        
        print("✅ Player data loaded successfully")
        return gameState
    }
}

// MARK: - Errors

enum AuthError: Error {
    case needsUserInteraction
    case notAuthenticated
    case playerNotFound
}
