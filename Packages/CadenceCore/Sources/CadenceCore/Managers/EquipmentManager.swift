import Foundation

/// Manages equipment purchases, inventory, and bonuses
public final class EquipmentManager {
    
    public init() {}
    
    // MARK: - Purchase Equipment
    
    /// Purchase equipment from the shop catalog
    public func purchaseEquipment(
        gameState: inout CadenceCore.GameState,
        catalogItem: EquipmentCatalogItem
    ) throws {
        // Check if player has enough money
        guard gameState.wallet.balance >= catalogItem.price else {
            throw EquipmentError.insufficientFunds
        }
        
        // Create the equipment instance
        let equipment = catalogItem.createEquipment(for: gameState.player.id)
        
        // Deduct cost from wallet
        try gameState.wallet.deductExpense(catalogItem.price)
        
        // Add to player's inventory
        gameState.addEquipment(equipment)
    }
    
    // MARK: - Repair Equipment
    
    /// Repair equipment to full durability
    public func repairEquipment(
        gameState: inout CadenceCore.GameState,
        equipmentID: UUID
    ) throws {
        guard var equipment = gameState.equipment(for: equipmentID) else {
            throw EquipmentError.equipmentNotFound
        }
        
        let cost = equipment.repairCost
        
        // Check if player has enough money
        guard gameState.wallet.balance >= cost else {
            throw EquipmentError.insufficientFunds
        }
        
        // Deduct repair cost
        try gameState.wallet.deductExpense(cost)
        
        // Repair the equipment
        equipment.repair()
        gameState.updateEquipment(equipment)
    }
    
    // MARK: - Sell Equipment
    
    /// Sell equipment for 50% of base price
    public func sellEquipment(
        gameState: inout CadenceCore.GameState,
        equipmentID: UUID
    ) throws {
        guard let equipment = gameState.equipment(for: equipmentID) else {
            throw EquipmentError.equipmentNotFound
        }
        
        // Calculate sell price (50% of base price, adjusted for durability)
        let durabilityMultiplier = Decimal(equipment.durability) / 100
        let sellPrice = equipment.basePrice * 0.5 * durabilityMultiplier
        
        // Add money to wallet
        gameState.wallet.addIncome(sellPrice)
        
        // Remove from inventory
        gameState.removeEquipment(equipmentID)
    }
    
    // MARK: - Equipment Bonuses
    
    /// Get the best equipment bonus for a specific skill type
    public func getBestEquipmentBonus(
        gameState: CadenceCore.GameState,
        for skillType: Skill.SkillType
    ) -> Double {
        // Find all equipment that boosts this skill
        let relevantEquipment = gameState.equipmentInventory.filter { equipment in
            equipment.equipmentType.relatedSkill == skillType && equipment.isUsable
        }
        
        // Get the highest bonus
        let bestBonus = relevantEquipment
            .map { $0.performanceBonus }
            .max() ?? 1.0
        
        return bestBonus
    }
    
    /// Get total value of all equipment
    public func getTotalInventoryValue(gameState: CadenceCore.GameState) -> Decimal {
        gameState.equipmentInventory.reduce(Decimal(0)) { total, equipment in
            let durabilityMultiplier = Decimal(equipment.durability) / 100
            return total + (equipment.basePrice * durabilityMultiplier)
        }
    }
    
    /// Get equipment that needs repair
    public func getEquipmentNeedingRepair(gameState: CadenceCore.GameState) -> [Equipment] {
        gameState.equipmentInventory.filter { $0.needsRepair }
    }
    
    /// Get equipment by type
    public func getEquipment(
        gameState: CadenceCore.GameState,
        ofType type: Equipment.EquipmentType
    ) -> [Equipment] {
        gameState.equipmentInventory.filter { $0.equipmentType == type }
    }
    
    /// Check if player owns equipment of a specific type
    public func ownsEquipment(
        gameState: CadenceCore.GameState,
        ofType type: Equipment.EquipmentType
    ) -> Bool {
        gameState.equipmentInventory.contains { $0.equipmentType == type && $0.isUsable }
    }
    
    // MARK: - Durability Management
    
    /// Reduce durability of all equipment (called periodically)
    public func degradeEquipment(
        gameState: inout CadenceCore.GameState,
        amount: Int = 1
    ) {
        for (index, _) in gameState.equipmentInventory.enumerated() {
            gameState.equipmentInventory[index].reduceDurability(by: amount)
        }
    }
    
    /// Reduce durability of specific equipment type after use
    public func degradeEquipmentAfterUse(
        gameState: inout CadenceCore.GameState,
        equipmentType: Equipment.EquipmentType,
        amount: Int = 1
    ) {
        // Find the best equipment of this type
        if let index = gameState.equipmentInventory.firstIndex(where: {
            $0.equipmentType == equipmentType && $0.isUsable
        }) {
            gameState.equipmentInventory[index].reduceDurability(by: amount)
        }
    }
}

// MARK: - Equipment Errors

public enum EquipmentError: Error, LocalizedError {
    case insufficientFunds
    case equipmentNotFound
    case equipmentUnusable
    case alreadyOwnsMaximum
    
    public var errorDescription: String? {
        switch self {
        case .insufficientFunds:
            return "Not enough money to complete this transaction"
        case .equipmentNotFound:
            return "Equipment not found in inventory"
        case .equipmentUnusable:
            return "This equipment is too damaged to use"
        case .alreadyOwnsMaximum:
            return "You already own the maximum number of this equipment type"
        }
    }
}
