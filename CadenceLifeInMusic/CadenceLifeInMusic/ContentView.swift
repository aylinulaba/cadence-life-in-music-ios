import SwiftUI
import CadenceCore
import CadenceUI

struct ContentView: View {
    @State private var hasCompletedOnboarding = false
    @State private var gameStateViewModel: GameStateViewModel?
    
    var body: some View {
        Group {
            if hasCompletedOnboarding, let viewModel = gameStateViewModel {
                HomeView(viewModel: viewModel)
            } else {
                OnboardingView(onComplete: { player in
                    let gameState = GameState.new(player: player)
                    gameStateViewModel = GameStateViewModel(gameState: gameState)
                    hasCompletedOnboarding = true
                })
            }
        }
    }
}

#Preview {
    ContentView()
}
