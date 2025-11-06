import SwiftUI
import CadenceCore

struct ContentView: View {
    @State private var gameState: GameState?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if let error = errorMessage {
                ErrorView(message: error) {
                    Task {
                        await authenticate()
                    }
                }
            } else if let state = gameState {
                MainGameView(gameState: state)
            }
        }
        .task {
            await authenticate()
        }
    }
    
    private func authenticate() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔐 Starting authentication...")
            
            let gameCenterID = try await AuthService.shared.authenticateWithGameCenter()
            
            let playerID = try await AuthService.shared.findOrCreatePlayer(
                gameCenterID: gameCenterID,
                defaultName: "Player"
            )
            
            let loadedState = try await AuthService.shared.loadPlayerData(playerID: playerID)
            
            gameState = loadedState
            isLoading = false
            
            print("✅ Authentication complete!")
            
        } catch {
            print("❌ Authentication failed: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

struct MainGameView: View {
    let gameState: GameState
    
    var body: some View {
        HomeView(viewModel: GameStateViewModel(gameState: gameState))
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.headline)
        }
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title)
            
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                retry()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
