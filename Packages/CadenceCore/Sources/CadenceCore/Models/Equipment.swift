import Foundation

/// Represents a musical instrument or production equipment
public struct Equipment: Identifiable, Codable, Sendable {
    public let id: UUID
    public let equipmentType: EquipmentType
    public let tier: EquipmentTier
    public let name: String
    public let basePrice: Decimal
    public var durability: Int // 0-100
    public let purchasedAt: Date
    public var ownerID: UUID
    
    public init(
        id: UUID = UUID(),
        equipmentType: EquipmentType,
        tier: EquipmentTier,
        name: String,
        basePrice: Decimal,
        durability: Int = 100,
        purchasedAt: Date = Date(),
        ownerID: UUID
    ) {
        self.id = id
        self.equipmentType = equipmentType
        self.tier = tier
        self.name = name
        self.basePrice = basePrice
        self.durability = durability
        self.purchasedAt = purchasedAt
        self.ownerID = ownerID
    }
    
    // MARK: - Equipment Type
    
    public enum EquipmentType: String, Codable, CaseIterable, Sendable {
        case guitar
        case piano
        case drums
        case bass
        case microphone
        case productionGear
        
        public var displayName: String {
            switch self {
            case .guitar: return "Guitar"
            case .piano: return "Piano"
            case .drums: return "Drums"
            case .bass: return "Bass"
            case .microphone: return "Microphone"
            case .productionGear: return "Production Gear"
            }
        }
        
        public var emoji: String {
            switch self {
            case .guitar: return "🎸"
            case .piano: return "🎹"
            case .drums: return "🥁"
            case .bass: return "🎸"
            case .microphone: return "🎤"
            case .productionGear: return "🎛️"
            }
        }
        
        /// The skill type associated with this equipment
        public var relatedSkill: Skill.SkillType {
            switch self {
            case .guitar: return .guitar
            case .piano: return .piano
            case .drums: return .drums
            case .bass: return .bass
            case .microphone: return .performance
            case .productionGear: return .production
            }
        }
    }
    
    // MARK: - Equipment Tier
    
    public enum EquipmentTier: String, Codable, CaseIterable, Sendable {
        case basic
        case professional
        case legendary
        
        public var displayName: String {
            switch self {
            case .basic: return "Basic"
            case .professional: return "Professional"
            case .legendary: return "Legendary"
            }
        }
        
        /// Performance bonus multiplier
        public var bonusMultiplier: Double {
            switch self {
            case .basic: return 1.0      // No bonus
            case .professional: return 1.25  // 25% bonus
            case .legendary: return 1.5   // 50% bonus
            }
        }
        
        /// Color coding for UI
        public var color: String {
            switch self {
            case .basic: return "gray"
            case .professional: return "blue"
            case .legendary: return "purple"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Whether the equipment is still in good condition
    public var isUsable: Bool {
        durability > 10
    }
    
    /// Whether the equipment needs repair
    public var needsRepair: Bool {
        durability < 50
    }
    
    /// Current performance bonus based on tier and durability
    public var performanceBonus: Double {
        let tierBonus = tier.bonusMultiplier
        let durabilityMultiplier = Double(durability) / 100.0
        return tierBonus * durabilityMultiplier
    }
    
    /// Repair cost based on durability loss
    public var repairCost: Decimal {
        let damagePercent = (100 - durability) / 100
        return basePrice * Decimal(damagePercent) * 0.3
    }
    
    // MARK: - Methods
    
    /// Reduce durability from use
    public mutating func reduceDurability(by amount: Int = 1) {
        durability = max(0, durability - amount)
    }
    
    /// Repair equipment to full durability
    public mutating func repair() {
        durability = 100
    }
}

// MARK: - Equipment Catalog

extension Equipment {
    /// All available equipment items in the shop
    public static let catalog: [EquipmentCatalogItem] = [
        // GUITARS
        EquipmentCatalogItem(
            equipmentType: .guitar,
            tier: .basic,
            name: "Beginner's Acoustic",
            price: 150
        ),
        EquipmentCatalogItem(
            equipmentType: .guitar,
            tier: .professional,
            name: "Fender Stratocaster",
            price: 1200
        ),
        EquipmentCatalogItem(
            equipmentType: .guitar,
            tier: .legendary,
            name: "Gibson Les Paul Custom",
            price: 4500
        ),
        
        // PIANOS
        EquipmentCatalogItem(
            equipmentType: .piano,
            tier: .basic,
            name: "Digital Keyboard",
            price: 200
        ),
        EquipmentCatalogItem(
            equipmentType: .piano,
            tier: .professional,
            name: "Yamaha Digital Piano",
            price: 1500
        ),
        EquipmentCatalogItem(
            equipmentType: .piano,
            tier: .legendary,
            name: "Steinway Grand Piano",
            price: 50000
        ),
        
        // DRUMS
        EquipmentCatalogItem(
            equipmentType: .drums,
            tier: .basic,
            name: "Entry Drum Kit",
            price: 300
        ),
        EquipmentCatalogItem(
            equipmentType: .drums,
            tier: .professional,
            name: "Pearl Export Series",
            price: 2000
        ),
        EquipmentCatalogItem(
            equipmentType: .drums,
            tier: .legendary,
            name: "DW Collector's Series",
            price: 8000
        ),
        
        // BASS
        EquipmentCatalogItem(
            equipmentType: .bass,
            tier: .basic,
            name: "Starter Bass Guitar",
            price: 180
        ),
        EquipmentCatalogItem(
            equipmentType: .bass,
            tier: .professional,
            name: "Fender Precision Bass",
            price: 1400
        ),
        EquipmentCatalogItem(
            equipmentType: .bass,
            tier: .legendary,
            name: "Music Man StingRay",
            price: 3500
        ),
        
        // MICROPHONES
        EquipmentCatalogItem(
            equipmentType: .microphone,
            tier: .basic,
            name: "USB Microphone",
            price: 80
        ),
        EquipmentCatalogItem(
            equipmentType: .microphone,
            tier: .professional,
            name: "Shure SM7B",
            price: 400
        ),
        EquipmentCatalogItem(
            equipmentType: .microphone,
            tier: .legendary,
            name: "Neumann U87",
            price: 3500
        ),
        
        // PRODUCTION GEAR
        EquipmentCatalogItem(
            equipmentType: .productionGear,
            tier: .basic,
            name: "Basic Audio Interface",
            price: 100
        ),
        EquipmentCatalogItem(
            equipmentType: .productionGear,
            tier: .professional,
            name: "Focusrite Scarlett 18i20",
            price: 550
        ),
        EquipmentCatalogItem(
            equipmentType: .productionGear,
            tier: .legendary,
            name: "Universal Audio Apollo",
            price: 2500
        ),
    ]
    
    /// Get catalog items filtered by type
    public static func catalogItems(for type: EquipmentType) -> [EquipmentCatalogItem] {
        catalog.filter { $0.equipmentType == type }
    }
    
    /// Get catalog items filtered by tier
    public static func catalogItems(for tier: EquipmentTier) -> [EquipmentCatalogItem] {
        catalog.filter { $0.tier == tier }
    }
}

// MARK: - Equipment Catalog Item

/// Represents an item in the equipment shop catalog
public struct EquipmentCatalogItem: Identifiable, Sendable {
    public let id: UUID
    public let equipmentType: Equipment.EquipmentType
    public let tier: Equipment.EquipmentTier
    public let name: String
    public let price: Decimal
    
    public init(
        id: UUID = UUID(),
        equipmentType: Equipment.EquipmentType,
        tier: Equipment.EquipmentTier,
        name: String,
        price: Decimal
    ) {
        self.id = id
        self.equipmentType = equipmentType
        self.tier = tier
        self.name = name
        self.price = price
    }
    
    /// Create an owned equipment instance from this catalog item
    public func createEquipment(for ownerID: UUID) -> Equipment {
        Equipment(
            equipmentType: equipmentType,
            tier: tier,
            name: name,
            basePrice: price,
            ownerID: ownerID
        )
    }
}
