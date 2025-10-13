import SwiftUI
import CadenceCore
import CadenceUI

struct ContentView: View {
    @State private var hasCompletedOnboarding = false
    @State private var currentPlayer: Player?
    
    var body: some View {
        Group {
            if hasCompletedOnboarding, let player = currentPlayer {
                HomeView(player: player)
            } else {
                OnboardingView(onComplete: { player in
                    currentPlayer = player
                    hasCompletedOnboarding = true
                })
            }
        }
    }
}

#Preview {
    ContentView()
}
