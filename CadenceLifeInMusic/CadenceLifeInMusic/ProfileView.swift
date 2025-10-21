import SwiftUI
import CadenceCore

struct ProfileView: View {
    let viewModel: GameStateViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with Avatar and Name
                    ProfileHeaderView(player: viewModel.gameState.player)
                    
                    // Wallet Section
                    WalletSectionView(wallet: viewModel.gameState.wallet)
                    
                    // Attributes Section
                    AttributesSectionView(player: viewModel.gameState.player)
                    
                    // Skills Section
                    SkillsSectionView(skills: viewModel.gameState.skills)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

// MARK: - Profile Header

struct ProfileHeaderView: View {
    let player: Player
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            // Name
            Text(player.name)
                .font(.title.bold())
            
            // Gender Badge
            Text(player.gender.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Wallet Section

struct WalletSectionView: View {
    let wallet: Wallet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wallet")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Balance
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(formatDecimal(wallet.balance))")
                            .font(.title2.bold())
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Lifetime Stats
                HStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Earned")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(formatDecimal(wallet.lifetimeEarnings))")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Spent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(formatDecimal(wallet.lifetimeSpending))")
                            .font(.subheadline.bold())
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

// MARK: - Attributes Section

struct AttributesSectionView: View {
    let player: Player
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Attributes")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Health
                AttributeBarView(
                    icon: "heart.fill",
                    label: "Health",
                    value: player.health,
                    maxValue: 100,
                    color: .red
                )
                
                // Mood
                AttributeBarView(
                    icon: "face.smiling.fill",
                    label: "Mood",
                    value: player.mood,
                    maxValue: 100,
                    color: .orange
                )
                
                // Fame
                AttributeBarView(
                    icon: "star.fill",
                    label: "Fame",
                    value: player.fame,
                    maxValue: 1000,
                    color: .yellow
                )
                
                // Reputation
                AttributeBarView(
                    icon: "hand.thumbsup.fill",
                    label: "Reputation",
                    value: player.reputation,
                    maxValue: 100,
                    color: .blue
                )
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

struct AttributeBarView: View {
    let icon: String
    let label: String
    let value: Int
    let maxValue: Int
    let color: Color
    
    var progress: Double {
        min(Double(value) / Double(maxValue), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(label)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(value)/\(maxValue)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                    
                    // Progress
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Skills Section

struct SkillsSectionView: View {
    let skills: [Skill]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(skills) { skill in
                    SkillRowView(skill: skill)
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

struct SkillRowView: View {
    let skill: Skill
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(skill.skillType.emoji)
                    .font(.title3)
                
                Text(skill.skillType.displayName)
                    .font(.subheadline.bold())
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Level \(skill.currentLevel)")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                    
                    Text("\(skill.currentXP) XP")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // XP Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(3)
                    
                    // Progress
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * skill.progressToNextLevel)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            // XP to next level
            if skill.currentLevel < 100 {
                Text("\(skill.xpToNextLevel) XP to Level \(skill.currentLevel + 1)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("MAX LEVEL")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    let player = Player(
        name: "Test Player",
        gender: .nonBinary,
        avatarID: "default",
        currentCityID: City.losAngeles.id
    )
    let gameState = GameState.new(player: player)
    
    return ProfileView(viewModel: GameStateViewModel(gameState: gameState))
}
