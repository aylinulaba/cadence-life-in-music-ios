import Foundation

public struct GameState: Codable, Sendable {
    public var player: Player
    public var wallet: Wallet
    public var skills: [Skill]
    public var primaryFocus: TimeSlot
    public var freeTime: TimeSlot
    
    public init(
        player: Player,
        wallet: Wallet,
        skills: [Skill],
        primaryFocus: TimeSlot,
        freeTime: TimeSlot
    ) {
        self.player = player
        self.wallet = wallet
        self.skills = skills
        self.primaryFocus = primaryFocus
        self.freeTime = freeTime
    }
}

// MARK: - Factory Method
extension GameState {
    public static func new(player: Player) -> GameState {
        let wallet = Wallet(playerID: player.id)
        
        // Initialize basic skills at level 0
        let skills = Skill.SkillType.allCases.map { skillType in
            Skill(playerID: player.id, skillType: skillType)
        }
        
        let primaryFocus = TimeSlot(
            playerID: player.id,
            slotType: .primaryFocus
        )
        
        let freeTime = TimeSlot(
            playerID: player.id,
            slotType: .freeTime
        )
        
        return GameState(
            player: player,
            wallet: wallet,
            skills: skills,
            primaryFocus: primaryFocus,
            freeTime: freeTime
        )
    }
}

// MARK: - Skill Lookup
extension GameState {
    public func skill(for type: Skill.SkillType) -> Skill? {
        skills.first { $0.skillType == type }
    }
    
    public mutating func updateSkill(_ skill: Skill) {
        if let index = skills.firstIndex(where: { $0.id == skill.id }) {
            skills[index] = skill
        }
    }
}
