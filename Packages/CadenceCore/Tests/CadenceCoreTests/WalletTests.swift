import XCTest
@testable import CadenceCore

final class WalletTests: XCTestCase {
    
    func testWalletInitialization() {
        // Given
        let playerID = UUID()
        let wallet = Wallet(playerID: playerID)
        
        // Then
        XCTAssertEqual(wallet.balance, 500) // Starting balance
        XCTAssertEqual(wallet.lifetimeEarnings, 500)
        XCTAssertEqual(wallet.lifetimeSpending, 0)
        XCTAssertEqual(wallet.playerID, playerID)
    }
    
    func testAddIncome() {
        // Given
        var wallet = Wallet(playerID: UUID())
        let initialBalance = wallet.balance
        
        // When
        wallet.addIncome(100)
        
        // Then
        XCTAssertEqual(wallet.balance, initialBalance + 100)
        XCTAssertEqual(wallet.lifetimeEarnings, 600) // 500 + 100
    }
    
    func testDeductExpense_Success() {
        // Given
        var wallet = Wallet(playerID: UUID())
        
        // When
        XCTAssertNoThrow(try wallet.deductExpense(200))
        
        // Then
        XCTAssertEqual(wallet.balance, 300) // 500 - 200
        XCTAssertEqual(wallet.lifetimeSpending, 200)
    }
    
    func testDeductExpense_InsufficientFunds() {
        // Given
        var wallet = Wallet(playerID: UUID())
        
        // When/Then
        XCTAssertThrowsError(try wallet.deductExpense(1000)) { error in
            XCTAssertEqual(error as? Wallet.WalletError, .insufficientFunds)
        }
        
        // Balance should remain unchanged
        XCTAssertEqual(wallet.balance, 500)
        XCTAssertEqual(wallet.lifetimeSpending, 0)
    }
    
    func testFormattedBalance() {
        // Given
        let wallet = Wallet(playerID: UUID(), balance: 1234.56)
        
        // Then
        XCTAssertEqual(wallet.formattedBalance, "$1234.56")
    }
}
