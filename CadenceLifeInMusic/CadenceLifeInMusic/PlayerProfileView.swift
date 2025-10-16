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
                                color: healthColor(for: player.health)
                            )
                            
                            StatusRow(
                                label: "Mood",
                                value: player.mood,
                                emoji: player.moodStatus.emoji,
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

// MARK: - Status Row Component
struct StatusRow: View {
    let label: String
    let value: Int
    let emoji: String
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
        health: 75,
        mood: 85
    )
    let gameState = GameState.new(player: player)
    let viewModel = GameStateViewModel(gameState: gameState)
    
    return PlayerProfileView(viewModel: viewModel)
}
