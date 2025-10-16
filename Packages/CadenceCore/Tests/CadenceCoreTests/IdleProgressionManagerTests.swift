import XCTest
@testable import CadenceCore

final class IdleProgressionManagerTests: XCTestCase {
    
    var manager: IdleProgressionManager!
    
    override func setUp() {
        super.setUp()
        manager = IdleProgressionManager()
    }
    
    override func tearDown() {
        manager = nil
        super.tearDown()
    }
    
    func testCalculateSkillXP_PracticeActivity() {
        // Given
        let activity = Activity.practice(instrument: .guitar)
        let elapsedTime: TimeInterval = 3600 // 1 hour
        let playerMood = 70
        
        // When
        let xpGain = manager.calculateSkillXP(
            activity: activity,
            elapsedTime: elapsedTime,
            playerMood: playerMood
        )
        
        // Then - Should be around 100 XP for 1 hour at mood 70
        XCTAssertGreaterThan(xpGain, 90)
        XCTAssertLessThan(xpGain, 110)
    }
    
    func testCalculateSkillXP_NonPracticeActivity() {
        // Given
        let activity = Activity.rest
        let elapsedTime: TimeInterval = 3600
        let playerMood = 70
        
        // When
        let xpGain = manager.calculateSkillXP(
            activity: activity,
            elapsedTime: elapsedTime,
            playerMood: playerMood
        )
        
        // Then - Should be 0 for non-practice activities
        XCTAssertEqual(xpGain, 0)
    }
    
    func testCalculateSkillXP_MoodModifier() {
        // Given
        let activity = Activity.practice(instrument: .guitar)
        let elapsedTime: TimeInterval = 3600
        
        // When - Low mood (20)
        let lowMoodXP = manager.calculateSkillXP(
            activity: activity,
            elapsedTime: elapsedTime,
            playerMood: 20
        )
        
        // When - High mood (100)
        let highMoodXP = manager.calculateSkillXP(
            activity: activity,
            elapsedTime: elapsedTime,
            playerMood: 100
        )
        
        // Then - High mood should give more XP
        XCTAssertGreaterThan(highMoodXP, lowMoodXP)
    }
    
    func testCalculateRecovery_RestActivity() {
        // Given
        let activity = Activity.rest
        let elapsedTime: TimeInterval = 3600 // 1 hour
        let currentHealth = 50
        let currentMood = 60
        
        // When
        let recovery = manager.calculateRecovery(
            activity: activity,
            elapsedTime: elapsedTime,
            currentHealth: currentHealth,
            currentMood: currentMood
        )
        
        // Then - Should gain 10 health and 5 mood per hour
        XCTAssertEqual(recovery.healthGain, 10)
        XCTAssertEqual(recovery.moodGain, 5)
    }
    
    func testCalculateRecovery_CappedAtMaximum() {
        // Given
        let activity = Activity.rest
        let elapsedTime: TimeInterval = 36000 // 10 hours (more than needed)
        let currentHealth = 95
        let currentMood = 98
        
        // When
        let recovery = manager.calculateRecovery(
            activity: activity,
            elapsedTime: elapsedTime,
            currentHealth: currentHealth,
            currentMood: currentMood
        )
        
        // Then - Should cap at 100
        XCTAssertEqual(recovery.healthGain, 5) // 100 - 95
        XCTAssertEqual(recovery.moodGain, 2) // 100 - 98
    }
    
    func testProcessIdleProgress_GuitarPractice() {
        // Given
        let player = Player(
            name: "Test Player",
            gender: .nonBinary,
            avatarID: "test",
            currentCityID: City.losAngeles.id,
            health: 80,
            mood: 70
        )
        var gameState = GameState.new(player: player)
        
        // Set practice guitar activity
        let guitarActivity = Activity.practice(instrument: .guitar)
        gameState.primaryFocus.currentActivity = guitarActivity
        gameState.primaryFocus.startedAt = Date().addingTimeInterval(-3600) // 1 hour ago
        
        // When
        manager.processIdleProgress(gameState: &gameState, currentTime: Date())
        
        // Then - Guitar skill should have gained XP
        if let guitarSkill = gameState.skill(for: .guitar) {
            XCTAssertGreaterThan(guitarSkill.currentXP, 0)
            XCTAssertLessThan(guitarSkill.currentXP, 200) // Reasonable upper bound
        } else {
            XCTFail("Guitar skill should exist")
        }
    }
    
    func testProcessIdleProgress_Rest() {
        // Given
        let player = Player(
            name: "Test Player",
            gender: .nonBinary,
            avatarID: "test",
            currentCityID: City.losAngeles.id,
            health: 50,
            mood: 60
        )
        var gameState = GameState.new(player: player)
        
        // Set rest activity
        gameState.primaryFocus.currentActivity = .rest
        gameState.primaryFocus.startedAt = Date().addingTimeInterval(-3600) // 1 hour ago
        
        // When
        manager.processIdleProgress(gameState: &gameState, currentTime: Date())
        
        // Then - Health and mood should increase
        XCTAssertGreaterThan(gameState.player.health, 50)
        XCTAssertGreaterThan(gameState.player.mood, 60)
    }
}
