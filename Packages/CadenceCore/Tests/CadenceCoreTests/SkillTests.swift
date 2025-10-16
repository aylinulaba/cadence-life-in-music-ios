import XCTest
@testable import CadenceCore

final class SkillTests: XCTestCase {
    
    func testSkillInitialization() {
        // Given
        let playerID = UUID()
        let skill = Skill(
            playerID: playerID,
            skillType: .guitar,
            currentXP: 0,
            currentLevel: 0
        )
        
        // Then
        XCTAssertEqual(skill.skillType, .guitar)
        XCTAssertEqual(skill.currentXP, 0)
        XCTAssertEqual(skill.currentLevel, 0)
        XCTAssertEqual(skill.playerID, playerID)
    }
    
    func testXPRequiredCalculation() {
        // Test XP formula: 100 × level^1.5
        XCTAssertEqual(Skill.xpRequired(for: 0), 0)
        XCTAssertEqual(Skill.xpRequired(for: 1), 100)
        XCTAssertEqual(Skill.xpRequired(for: 2), 282) // 100 * 2^1.5 ≈ 282
        XCTAssertEqual(Skill.xpRequired(for: 10), 3162) // 100 * 10^1.5 ≈ 3162
    }
    
    func testAddXP() {
        // Given
        var skill = Skill(
            playerID: UUID(),
            skillType: .guitar,
            currentXP: 0,
            currentLevel: 0
        )
        
        // When
        skill.addXP(50)
        
        // Then
        XCTAssertEqual(skill.currentXP, 50)
        XCTAssertEqual(skill.currentLevel, 0) // Not enough for level 1 (needs 100)
    }
    
    func testLevelUp() {
        // Given
        var skill = Skill(
            playerID: UUID(),
            skillType: .guitar,
            currentXP: 0,
            currentLevel: 0
        )
        
        // When - Add enough XP to reach level 1
        skill.addXP(100)
        
        // Then
        XCTAssertEqual(skill.currentLevel, 1)
        XCTAssertEqual(skill.currentXP, 100)
    }
    
    func testMultipleLevelUps() {
        // Given
        var skill = Skill(
            playerID: UUID(),
            skillType: .piano,
            currentXP: 0,
            currentLevel: 0
        )
        
        // When - Add 500 XP (should level up to level 2)
        skill.addXP(500)
        
        // Then
        XCTAssertEqual(skill.currentLevel, 2)
        XCTAssertEqual(skill.currentXP, 500)
    }
    
    func testProgressToNextLevel() {
        // Given
        var skill = Skill(
            playerID: UUID(),
            skillType: .drums,
            currentXP: 0,
            currentLevel: 0
        )
        
        // When
        skill.addXP(50) // Half way to level 1
        
        // Then
        XCTAssertEqual(skill.progressToNextLevel, 0.5, accuracy: 0.01)
    }
    
    func testSkillTypeDisplayName() {
        XCTAssertEqual(Skill.SkillType.guitar.displayName, "Guitar")
        XCTAssertEqual(Skill.SkillType.piano.displayName, "Piano")
        XCTAssertEqual(Skill.SkillType.songwriting.displayName, "Songwriting")
    }
}
