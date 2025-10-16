import XCTest
@testable import CadenceCore

final class PlayerTests: XCTestCase {
    
    func testPlayerInitialization() {
        // Given
        let player = Player(
            name: "Test Artist",
            gender: .male,
            avatarID: "avatar1",
            currentCityID: City.losAngeles.id
        )
        
        // Then
        XCTAssertEqual(player.name, "Test Artist")
        XCTAssertEqual(player.gender, .male)
        XCTAssertEqual(player.health, 80) // Default
        XCTAssertEqual(player.mood, 70) // Default
        XCTAssertEqual(player.fame, 0)
        XCTAssertEqual(player.reputation, 50)
    }
    
    func testPlayerHealthStatus() {
        // Given
        let playerCritical = Player(
            name: "Test",
            gender: .female,
            avatarID: "test",
            currentCityID: City.tokyo.id,
            health: 15
        )
        let playerExcellent = Player(
            name: "Test",
            gender: .female,
            avatarID: "test",
            currentCityID: City.tokyo.id,
            health: 95
        )
        
        // Then
        XCTAssertEqual(playerCritical.healthStatus, .critical)
        XCTAssertEqual(playerExcellent.healthStatus, .excellent)
    }
    
    func testPlayerMoodStatus() {
        // Given
        let playerDepressed = Player(
            name: "Test",
            gender: .nonBinary,
            avatarID: "test",
            currentCityID: City.istanbul.id,
            mood: 10
        )
        let playerEuphoric = Player(
            name: "Test",
            gender: .nonBinary,
            avatarID: "test",
            currentCityID: City.istanbul.id,
            mood: 95
        )
        
        // Then
        XCTAssertEqual(playerDepressed.moodStatus, .depressed)
        XCTAssertEqual(playerEuphoric.moodStatus, .euphoric)
    }
    
    func testGenderDisplayName() {
        XCTAssertEqual(Player.Gender.male.displayName, "Male")
        XCTAssertEqual(Player.Gender.female.displayName, "Female")
        XCTAssertEqual(Player.Gender.nonBinary.displayName, "Non-binary")
    }
}
