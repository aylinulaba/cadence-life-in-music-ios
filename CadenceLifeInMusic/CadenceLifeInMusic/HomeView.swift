import SwiftUI
import CadenceCore
import CadenceUI

struct HomeView: View {
    let player: Player
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlayerProfileView(player: player)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(0)
            
            MusicView()
                .tabItem {
                    Label("Music", systemImage: "music.note")
                }
                .tag(1)
            
            EconomyView()
                .tabItem {
                    Label("Economy", systemImage: "dollarsign.circle")
                }
                .tag(2)
            
            SocialView()
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
                .tag(3)
        }
    }
}

#Preview {
    HomeView(player: Player(
        name: "Demo Artist",
        gender: .nonBinary,
        avatarID: "default",
        currentCityID: City.losAngeles.id
    ))
}
