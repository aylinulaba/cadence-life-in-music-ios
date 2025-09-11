import SwiftUI

@main
struct CadenceLifeInMusicApp: App {
    @StateObject private var router = OnboardingRouter()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
        }
    }
}
