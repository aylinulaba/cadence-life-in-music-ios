import Foundation

public struct Wallet: Identifiable, Codable, Sendable {
    public let id: UUID
    public let playerID: UUID
    public var balance: Decimal
    public var lifetimeEarnings: Decimal
    public var lifetimeSpending: Decimal
    
    public init(
        id: UUID = UUID(),
        playerID: UUID,
        balance: Decimal = 500, // Starting balance
        lifetimeEarnings: Decimal = 500,
        lifetimeSpending: Decimal = 0
    ) {
        self.id = id
        self.playerID = playerID
        self.balance = balance
        self.lifetimeEarnings = lifetimeEarnings
        self.lifetimeSpending = lifetimeSpending
    }
}

// MARK: - Transaction Operations
extension Wallet {
    public mutating func addIncome(_ amount: Decimal) {
        balance += amount
        lifetimeEarnings += amount
    }
    
    public mutating func deductExpense(_ amount: Decimal) throws {
        guard balance >= amount else {
            throw WalletError.insufficientFunds
        }
        balance -= amount
        lifetimeSpending += amount
    }
    
    public enum WalletError: Error, LocalizedError {
        case insufficientFunds
        
        public var errorDescription: String? {
            switch self {
            case .insufficientFunds:
                return "Insufficient funds. You need more money to complete this transaction."
            }
        }
    }
}

// MARK: - Formatting
extension Wallet {
    public var formattedBalance: String {
        "$\(balance)"
    }
    
    public var formattedLifetimeEarnings: String {
        "$\(lifetimeEarnings)"
    }
    
    public var formattedLifetimeSpending: String {
        "$\(lifetimeSpending)"
    }
}
