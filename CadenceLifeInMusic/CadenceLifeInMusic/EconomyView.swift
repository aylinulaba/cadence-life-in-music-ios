import SwiftUI
import CadenceCore
import CadenceUI

struct EconomyView: View {
    let viewModel: GameStateViewModel
    
    var wallet: Wallet {
        viewModel.gameState.wallet
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Balance Card
                    VStack(spacing: Spacing.sm) {
                        Text("Current Balance")
                            .font(.cadenceCaption)
                            .foregroundStyle(.secondary)
                        
                        Text(wallet.formattedBalance)
                            .font(.cadenceStat)
                            .foregroundStyle(.cadencePrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.xl)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    
                    // Lifetime Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Spacing.md) {
                        StatCard(
                            title: "Total Earned",
                            value: wallet.formattedLifetimeEarnings,
                            icon: "arrow.down.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Total Spent",
                            value: wallet.formattedLifetimeSpending,
                            icon: "arrow.up.circle.fill",
                            color: .red
                        )
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.cadencePrimary)
                            Text("Your Wallet")
                                .font(.cadenceBodyBold)
                        }
                        
                        Text("Earn money from jobs and gigs. Spend on equipment, housing, and travel. Keep an eye on your balance!")
                            .font(.cadenceBody)
                            .foregroundStyle(.secondary)
                    }
                    .padding(Spacing.md)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Economy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let player = Player(
        name: "Demo Artist",
        gender: .nonBinary,
        avatarID: "default",
        currentCityID: City.losAngeles.id
    )
    let gameState = GameState.new(player: player)
    let viewModel = GameStateViewModel(gameState: gameState)
    
    return EconomyView(viewModel: viewModel)
}
