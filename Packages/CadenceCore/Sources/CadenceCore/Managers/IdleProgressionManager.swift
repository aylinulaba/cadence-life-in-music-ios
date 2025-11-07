import Foundation
import CadenceCore

public final class IdleProgressionManager: Sendable {
    
    private let jobPaymentManager = JobPaymentManager()
    private let equipmentManager = EquipmentManager()
    private let healthMoodManager = HealthMoodManager()
    
    public init() {}
    
    public func calculateSkillXP(
        activity: Activity,
        elapsedTime: TimeInterval,
        playerMood: Int,
        equipmentBonus: Double = 1.0
    ) -> Int {
        guard activity.type == .practice else { return 0 }
        
        let baseXPPerSecond = 10.0 / 3600.0
        let moodModifier = 0.7 + (Double(playerMood) / 100.0) * 0.5
        let totalXP = baseXPPerSecond * elapsedTime * moodModifier * equipmentBonus
        
        return Int(totalXP)
    }
    
    public func calculateRecovery(
        activity: Activity,
        elapsedTime: TimeInterval,
        currentHealth: Int,
        currentMood: Int
    ) -> (healthGain: Int, moodGain: Int) {
        guard activity.type == .rest else { return (0, 0) }
        
        let hours = elapsedTime / 3600.0
        
        // Use HealthMoodManager for more sophisticated calculations
        let healthGain = healthMoodManager.calculateRestHealthRecovery(
            hoursRested: hours,
            currentHealth: currentHealth
        )
        let moodGain = healthMoodManager.calculateRestMoodBoost(
            hoursRested: hours,
            currentMood: currentMood
        )
        
        // Cap gains to not exceed 100
        let cappedHealthGain = min(healthGain, 100 - currentHealth)
        let cappedMoodGain = min(moodGain, 100 - currentMood)
        
        return (cappedHealthGain, cappedMoodGain)
    }
    
    public func calculatePassiveDecay(
        timeSinceLastUpdate: TimeInterval
    ) -> (healthLoss: Int, moodLoss: Int) {
        let hours = timeSinceLastUpdate / 3600.0
        let healthLoss = Int(hours * (2.0 / 24.0))
        let moodLoss = Int(hours * (1.0 / 24.0))
        
        return (healthLoss, moodLoss)
    }
    
    public func processIdleProgress(
        gameState: inout CadenceCore.GameState,
        currentTime: Date = Date()
    ) {
        var player = gameState.player
        
        // Process Primary Focus activity
        if let activity = gameState.primaryFocus.currentActivity,
           let startedAt = gameState.primaryFocus.startedAt {
            let elapsedTime = currentTime.timeIntervalSince(startedAt)
            
            switch activity.type {
            case .practice:
                if let skillType = extractSkillType(from: activity),
                   var skill = gameState.skill(for: skillType) {
                    
                    // Get equipment bonus for this skill
                    let equipmentBonus = equipmentManager.getBestEquipmentBonus(
                        gameState: gameState,
                        for: skillType
                    )
                    
                    // NEW: Get health/mood multiplier
                    let healthMoodMultiplier = healthMoodManager.getXPMultiplier(
                        health: player.health,
                        mood: player.mood
                    )
                    
                    // Calculate XP with all multipliers
                    let baseXP = calculateSkillXP(
                        activity: activity,
                        elapsedTime: elapsedTime,
                        playerMood: player.mood,
                        equipmentBonus: equipmentBonus
                    )
                    
                    let finalXP = Int(Double(baseXP) * healthMoodMultiplier)
                    
                    skill.addXP(finalXP)
                    gameState.updateSkill(skill)
                    
                    // Degrade equipment after practice
                    equipmentManager.degradeEquipmentAfterUse(
                        gameState: &gameState,
                        equipmentType: skillType.equipmentType,
                        amount: 1
                    )
                    
                    // NEW: Apply minor health/mood loss from extended practice
                    let hours = elapsedTime / 3600.0
                    if hours > 4 {
                        player.adjustHealth(by: -Int((hours - 4) * 0.5))
                        player.adjustMood(by: -Int((hours - 4) * 0.25))
                    }
                }
                
            case .rest:
                let recovery = calculateRecovery(
                    activity: activity,
                    elapsedTime: elapsedTime,
                    currentHealth: player.health,
                    currentMood: player.mood
                )
                player.adjustHealth(by: recovery.healthGain)
                player.adjustMood(by: recovery.moodGain)
                
            case .job:
                // NEW: Apply overwork penalty if working too long
                let hours = elapsedTime / 3600.0
                let healthLoss = healthMoodManager.calculateOverworkHealthLoss(hoursWorked: hours)
                if healthLoss > 0 {
                    player.adjustHealth(by: -healthLoss)
                    player.adjustMood(by: -Int(Double(healthLoss) * 0.5))
                }
                
            default:
                break
            }
        }
        
        // Process Free Time activity
        if let activity = gameState.freeTime.currentActivity,
           let startedAt = gameState.freeTime.startedAt {
            let elapsedTime = currentTime.timeIntervalSince(startedAt)
            
            switch activity.type {
            case .practice:
                if let skillType = extractSkillType(from: activity),
                   var skill = gameState.skill(for: skillType) {
                    
                    // Get equipment bonus for this skill
                    let equipmentBonus = equipmentManager.getBestEquipmentBonus(
                        gameState: gameState,
                        for: skillType
                    )
                    
                    // NEW: Get health/mood multiplier
                    let healthMoodMultiplier = healthMoodManager.getXPMultiplier(
                        health: player.health,
                        mood: player.mood
                    )
                    
                    // Calculate XP with all multipliers
                    let baseXP = calculateSkillXP(
                        activity: activity,
                        elapsedTime: elapsedTime,
                        playerMood: player.mood,
                        equipmentBonus: equipmentBonus
                    )
                    
                    let finalXP = Int(Double(baseXP) * healthMoodMultiplier)
                    
                    skill.addXP(finalXP)
                    gameState.updateSkill(skill)
                    
                    // Degrade equipment after practice
                    equipmentManager.degradeEquipmentAfterUse(
                        gameState: &gameState,
                        equipmentType: skillType.equipmentType,
                        amount: 1
                    )
                    
                    // NEW: Apply minor health/mood loss from extended practice
                    let hours = elapsedTime / 3600.0
                    if hours > 4 {
                        player.adjustHealth(by: -Int((hours - 4) * 0.5))
                        player.adjustMood(by: -Int((hours - 4) * 0.25))
                    }
                }
                
            case .rest:
                let recovery = calculateRecovery(
                    activity: activity,
                    elapsedTime: elapsedTime,
                    currentHealth: player.health,
                    currentMood: player.mood
                )
                player.adjustHealth(by: recovery.healthGain)
                player.adjustMood(by: recovery.moodGain)
                
            default:
                break
            }
        }
        
        // Process job payments
        jobPaymentManager.processDuePayments(gameState: &gameState)
        
        // Update player state
        gameState.player = player
        gameState.player.lastSyncAt = currentTime
    }
    
    private func extractSkillType(from activity: Activity) -> Skill.SkillType? {
        let name = activity.name.lowercased()
        
        for skillType in Skill.SkillType.allCases {
            if name.contains(skillType.rawValue) {
                return skillType
            }
        }
        return nil
    }
}

// MARK: - Skill Type Equipment Mapping

extension Skill.SkillType {
    /// The equipment type that boosts this skill
    public var equipmentType: Equipment.EquipmentType {
        switch self {
        case .guitar: return .guitar
        case .piano: return .piano
        case .drums: return .drums
        case .bass: return .bass
        case .songwriting: return .guitar // Default to guitar for songwriting
        case .performance: return .microphone
        case .production: return .productionGear
        }
    }
}
