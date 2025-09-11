import SwiftUI

struct ContentView: View {
    @EnvironmentObject var router: OnboardingRouter
    var body: some View {
        Group {
            switch router.step {
            case .splash: SplashView()
            case .name: NameView()
            case .avatar: AvatarView()
            case .vibe: VibeView()
            case .summary: SummaryView()
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(OnboardingRouter())
}
