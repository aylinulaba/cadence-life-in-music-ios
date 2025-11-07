import Foundation

/// Manages health and mood calculations and their impact on gameplay
public final class HealthMoodManager {
    
    public init() {}
    
    // MARK: - Status Levels
    
    public enum HealthStatus {
        case critical   // 0-20
        case poor       // 21-40
        case fair       // 41-60
        case good       // 61-80
        case excellent  // 81-100
        
        public var emoji: String {
            switch self {
            case .critical: return "💀"
            case .poor: return "🤕"
            case .fair: return "😐"
            case .good: return "😊"
            case .excellent: return "💪"
            }
        }
        
        public var displayName: String {
            switch self {
            case .critical: return "Critical"
            case .poor: return "Poor"
            case .fair: return "Fair"
            case .good: return "Good"
            case .excellent: return "Excellent"
            }
        }
        
        public var color: String {
            switch self {
            case .critical: return "red"
            case .poor: return "orange"
            case .fair: return "yellow"
            case .good: return "green"
            case .excellent: return "blue"
            }
        }
    }
    
    public enum MoodStatus {
        case depressed  // 0-20
        case sad        // 21-40
        case neutral    // 41-60
        case happy      // 61-80
        case euphoric   // 81-100
        
        public var emoji: String {
            switch self {
            case .depressed: return "😢"
            case .sad: return "😔"
            case .neutral: return "😐"
            case .happy: return "😊"
            case .euphoric: return "🤩"
            }
        }
        
        public var displayName: String {
            switch self {
            case .depressed: return "Depressed"
            case .sad: return "Sad"
            case .neutral: return "Neutral"
            case .happy: return "Happy"
            case .euphoric: return "Euphoric"
            }
        }
        
        public var color: String {
            switch self {
            case .depressed: return "red"
            case .sad: return "orange"
            case .neutral: return "yellow"
            case .happy: return "green"
            case .euphoric: return "purple"
            }
        }
    }
    
    // MARK: - Status Calculation
    
    public func getHealthStatus(health: Int) -> HealthStatus {
        switch health {
        case 0...20: return .critical
        case 21...40: return .poor
        case 41...60: return .fair
        case 61...80: return .good
        default: return .excellent
        }
    }
    
    public func getMoodStatus(mood: Int) -> MoodStatus {
        switch mood {
        case 0...20: return .depressed
        case 21...40: return .sad
        case 41...60: return .neutral
        case 61...80: return .happy
        default: return .euphoric
        }
    }
    
    // MARK: - Performance Modifiers
    
    /// Calculate XP multiplier based on health and mood
    public func getXPMultiplier(health: Int, mood: Int) -> Double {
        let healthMultiplier = getHealthMultiplier(health: health)
        let moodMultiplier = getMoodMultiplier(mood: mood)
        
        // Combined effect: both contribute to total multiplier
        let combinedMultiplier = (healthMultiplier + moodMultiplier) / 2.0
        
        return combinedMultiplier
    }
    
    /// Health affects physical ability (0.5x to 1.2x)
    public func getHealthMultiplier(health: Int) -> Double {
        switch health {
        case 0...20: return 0.5   // Critical: 50% effectiveness
        case 21...40: return 0.7  // Poor: 70% effectiveness
        case 41...60: return 0.9  // Fair: 90% effectiveness
        case 61...80: return 1.0  // Good: 100% effectiveness
        default: return 1.2       // Excellent: 120% effectiveness
        }
    }
    
    /// Mood affects creativity and focus (0.6x to 1.3x)
    public func getMoodMultiplier(mood: Int) -> Double {
        switch mood {
        case 0...20: return 0.6   // Depressed: 60% effectiveness
        case 21...40: return 0.8  // Sad: 80% effectiveness
        case 41...60: return 1.0  // Neutral: 100% effectiveness
        case 61...80: return 1.15 // Happy: 115% effectiveness
        default: return 1.3       // Euphoric: 130% effectiveness
        }
    }
    
    /// Calculate song quality modifier based on mood
    public func getSongQualityModifier(mood: Int) -> Double {
        // Mood heavily affects creativity
        switch mood {
        case 0...20: return 0.5   // Very poor quality when depressed
        case 21...40: return 0.75 // Below average
        case 41...60: return 1.0  // Normal quality
        case 61...80: return 1.2  // Good quality
        default: return 1.5       // Excellent quality when euphoric
        }
    }
    
    /// Calculate recording quality modifier based on health and mood
    public func getRecordingQualityModifier(health: Int, mood: Int) -> Double {
        let healthFactor = Double(health) / 100.0
        let moodFactor = Double(mood) / 100.0
        
        // Health affects technical execution, mood affects emotional delivery
        let combinedFactor = (healthFactor * 0.4) + (moodFactor * 0.6)
        
        // Range: 0.5 to 1.3
        return 0.5 + (combinedFactor * 0.8)
    }
    
    /// Calculate performance quality modifier for gigs
    public func getPerformanceQualityModifier(health: Int, mood: Int) -> Double {
        let healthFactor = Double(health) / 100.0
        let moodFactor = Double(mood) / 100.0
        
        // Both health and mood are critical for live performance
        let combinedFactor = (healthFactor * 0.5) + (moodFactor * 0.5)
        
        // Range: 0.4 to 1.4
        return 0.4 + (combinedFactor * 1.0)
    }
    
    // MARK: - Health & Mood Changes
    
    /// Calculate health loss from overwork
    public func calculateOverworkHealthLoss(hoursWorked: Double) -> Int {
        // Working more than 8 hours without rest causes health loss
        if hoursWorked > 8 {
            let excessHours = hoursWorked - 8
            return Int(excessHours * 2) // 2 health per excess hour
        }
        return 0
    }
    
    /// Calculate mood boost from successful gig
    public func calculateSuccessfulGigMoodBoost(attendance: Int, quality: Int) -> Int {
        let attendanceFactor = min(attendance / 100, 5) // Max +5 from attendance
        let qualityFactor = quality / 20 // Max +5 from quality
        return attendanceFactor + qualityFactor
    }
    
    /// Calculate mood loss from failed gig
    public func calculateFailedGigMoodLoss(expectedAttendance: Int, actualAttendance: Int) -> Int {
        let attendanceRatio = Double(actualAttendance) / Double(expectedAttendance)
        
        if attendanceRatio < 0.3 {
            return 15 // Severe disappointment
        } else if attendanceRatio < 0.5 {
            return 10 // Significant disappointment
        } else if attendanceRatio < 0.7 {
            return 5 // Mild disappointment
        }
        return 0
    }
    
    /// Calculate mood boost from rest
    public func calculateRestMoodBoost(hoursRested: Double, currentMood: Int) -> Int {
        // More effective when mood is low
        let baseBoost = Int(hoursRested * 5)
        
        if currentMood < 30 {
            return Int(Double(baseBoost) * 1.5) // 50% more effective when very low
        } else if currentMood < 50 {
            return Int(Double(baseBoost) * 1.2) // 20% more effective when low
        }
        return baseBoost
    }
    
    /// Calculate health recovery from rest
    public func calculateRestHealthRecovery(hoursRested: Double, currentHealth: Int) -> Int {
        // More effective when health is low
        let baseRecovery = Int(hoursRested * 10)
        
        if currentHealth < 30 {
            return Int(Double(baseRecovery) * 1.5) // 50% more effective when critical
        } else if currentHealth < 50 {
            return Int(Double(baseRecovery) * 1.2) // 20% more effective when low
        }
        return baseRecovery
    }
    
    // MARK: - Warnings & Recommendations
    
    public func shouldWarnLowHealth(health: Int) -> Bool {
        health < 30
    }
    
    public func shouldWarnLowMood(mood: Int) -> Bool {
        mood < 30
    }
    
    public func getHealthWarningMessage(health: Int) -> String? {
        guard shouldWarnLowHealth(health: health) else { return nil }
        
        if health < 20 {
            return "⚠️ Critical health! Rest immediately or your performance will suffer greatly."
        } else {
            return "⚠️ Low health. Consider resting to improve your performance."
        }
    }
    
    public func getMoodWarningMessage(mood: Int) -> String? {
        guard shouldWarnLowMood(mood: mood) else { return nil }
        
        if mood < 20 {
            return "😢 Your mood is very low. Take a break and rest to feel better."
        } else {
            return "😔 Your mood could be better. Resting or having a successful performance will help."
        }
    }
    
    public func getRecommendedAction(health: Int, mood: Int) -> String {
        if health < 30 && mood < 30 {
            return "You need to rest! Both your health and mood are low."
        } else if health < 30 {
            return "Rest to recover your health."
        } else if mood < 30 {
            return "Take a break to improve your mood."
        } else if health < 50 || mood < 50 {
            return "Consider resting to optimize your performance."
        } else {
            return "You're in good shape! Keep up the great work."
        }
    }
}
