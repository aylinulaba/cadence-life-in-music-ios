import SwiftUI
import CadenceCore
import CadenceUI

struct HomeView: View {
    let viewModel: GameStateViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlayerProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(0)
            
            MusicView(viewModel: viewModel)
                .tabItem {
                    Label("Music", systemImage: "music.note")
                }
                .tag(1)
            
            WorkView(viewModel: viewModel)
                .tabItem {
                    Label("Work", systemImage: "briefcase.fill")
                }
                .tag(2)
            
            EquipmentShopView(viewModel: viewModel)
                .tabItem {
                    Label("Equipment", systemImage: "bag.fill")
                }
                .tag(3)
            
            EconomyView(viewModel: viewModel)
                .tabItem {
                    Label("Economy", systemImage: "dollarsign.circle")
                }
                .tag(4)
            
            SocialView()
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
                .tag(5)
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
    
    return HomeView(viewModel: viewModel)
}
