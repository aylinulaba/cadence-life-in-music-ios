import SwiftUI
import CadenceCore
import CadenceUI

struct PlayerProfileView: View {
    let viewModel: GameStateViewModel
    
    var player: Player {
        viewModel.gameState.player
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    VStack(spacing: Spacing.sm) {
                        Text("🎤")
                            .font(.system(size: 80))
                        
                        Text(player.name)
                            .font(.cadenceTitle)
                        
                        Text(player.gender.displayName)
                            .font(.cadenceCaption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, Spacing.lg)
                    
                    // NEW: Health & Mood Warnings
                    if player.needsHealthWarning || player.needsMoodWarning {
                        WarningSection(player: player)
                    }
                    
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Spacing.md) {
                        StatCard(
                            title: "Health",
                            value: "\(player.health)",
                            icon: "heart.fill",
                            color: healthColor(for: player.health)
                        )
                        
                        StatCard(
                            title: "Mood",
                            value: "\(player.mood)",
                            icon: "face.smiling.fill",
                            color: moodColor(for: player.mood)
                        )
                        
                        StatCard(
                            title: "Fame",
                            value: "\(player.fame)",
                            icon: "star.fill",
                            color: .cadenceAccent
                        )
                        
                        StatCard(
                            title: "Reputation",
                            value: "\(player.reputation)",
                            icon: "trophy.fill",
                            color: .cadencePrimary
                        )
                    }
                    .id(viewModel.refreshTrigger)
                    
                    // Status Indicators
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Status")
                            .font(.cadenceHeadline)
                            .padding(.horizontal, Spacing.md)
                        
                        VStack(spacing: Spacing.sm) {
                            StatusRow(
                                label: "Health",
                                value: player.health,
                                emoji: player.healthStatus.emoji,
                                statusText: player.healthStatus.displayName,
                                color: healthColor(for: player.health)
                            )
                            
                            StatusRow(
                                label: "Mood",
                                value: player.mood,
                                emoji: player.moodStatus.emoji,
                                statusText: player.moodStatus.displayName,
                                color: moodColor(for: player.mood)
                            )
                        }
                        .padding(Spacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                    .id(viewModel.refreshTrigger)
                    
                    // Skills Section
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Skills")
                            .font(.cadenceHeadline)
                            .padding(.horizontal, Spacing.md)
                        
                        VStack(spacing: Spacing.sm) {
                            ForEach(Skill.SkillType.allCases, id: \.self) { skillType in
                                if let skill = viewModel.skill(for: skillType) {
                                    SkillRow(skill: skill)
                                }
                            }
                        }
                        .padding(Spacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                    .id(viewModel.refreshTrigger)
                    
                    Spacer()
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func healthColor(for value: Int) -> Color {
        switch value {
        case 0..<20: return .healthCritical
        case 20..<40: return .healthPoor
        case 40..<60: return .healthFair
        case 60..<80: return .healthGood
        default: return .healthExcellent
        }
    }
    
    private func moodColor(for value: Int) -> Color {
        switch value {
        case 0..<20: return .moodDepressed
        case 20..<40: return .moodSad
        case 40..<60: return .moodNeutral
        case 60..<80: return .moodHappy
        default: return .moodEuphoric
        }
    }
}

// MARK: - Warning Section (NEW)

struct WarningSection: View {
    let player: Player
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            if player.needsHealthWarning {
                WarningCard(
                    icon: "heart.fill",
                    title: "Low Health",
                    message: player.healthStatus.description,
                    color: .red
                )
            }
            
            if player.needsMoodWarning {
                WarningCard(
                    icon: "face.frowning.fill",
                    title: "Low Mood",
                    message: player.moodStatus.description,
                    color: .orange
                )
            }
            
            // Recommendation
            RecommendationCard(player: player)
        }
    }
}

// MARK: - Warning Card (NEW)

struct WarningCard: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.cadenceBodyBold)
                    .foregroundStyle(color)
                
                Text(message)
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Recommendation Card (NEW)

struct RecommendationCard: View {
    let player: Player
    
    private var recommendation: String {
        if player.health < 30 && player.mood < 30 {
            return "You need to rest! Both your health and mood are low."
        } else if player.health < 30 {
            return "Rest to recover your health."
        } else if player.mood < 30 {
            return "Take a break to improve your mood."
        } else if player.health < 50 || player.mood < 50 {
            return "Consider resting to optimize your performance."
        } else {
            return "You're in good shape! Keep up the great work."
        }
    }
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
            
            Text(recommendation)
                .font(.cadenceBody)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Status Row Component

struct StatusRow: View {
    let label: String
    let value: Int
    let emoji: String
    let statusText: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.title)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.cadenceBody)
                    Spacer()
                    Text("\(value)/100")
                        .font(.cadenceBodyBold)
                        .foregroundStyle(color)
                }
                
                Text(statusText)
                    .font(.cadenceCaption)
                    .foregroundStyle(color)
                
                ProgressBar(progress: Double(value) / 100.0, color: color)
            }
        }
    }
}

// MARK: - Skill Row Component

struct SkillRow: View {
    let skill: Skill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(skill.skillType.emoji)
                    .font(.title3)
                
                Text(skill.skillType.displayName)
                    .font(.cadenceBody)
                
                Spacer()
                
                Text("Lv \(skill.currentLevel)")
                    .font(.cadenceBodyBold)
                    .foregroundStyle(.cadencePrimary)
            }
            
            HStack {
                ProgressBar(
                    progress: skill.progressToNextLevel,
                    color: .cadencePrimary,
                    height: 6
                )
                
                Text("\(skill.currentXP) XP")
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    let player = Player(
        name: "Demo Artist",
        gender: .nonBinary,
        avatarID: "default",
        currentCityID: City.losAngeles.id,
        health: 25,
        mood: 35
    )
    let gameState = GameState.new(player: player)
    let viewModel = GameStateViewModel(gameState: gameState)
    
    return PlayerProfileView(viewModel: viewModel)
}
