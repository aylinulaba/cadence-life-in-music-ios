import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case splash, name, avatar, vibe, summary
}

enum Vibe: String, CaseIterable {
    case rock, pop, electronic, classical
}

final class OnboardingRouter: ObservableObject {
    @Published var step: OnboardingStep = .splash
    @Published var stageName: String = ""
    @Published var selectedAvatarID: Int? = nil
    @Published var selectedVibe: Vibe? = nil

    func next() {
        switch step {
        case .splash: step = .name
        case .name: step = .avatar
        case .avatar: step = .vibe
        case .vibe: step = .summary
        case .summary: break
        }
    }

    func back() {
        switch step {
        case .splash: break
        case .name: step = .splash
        case .avatar: step = .name
        case .vibe: step = .avatar
        case .summary: step = .vibe
        }
    }

    func reset() {
        stageName = ""
        selectedAvatarID = nil
        selectedVibe = nil
        step = .splash
    }
}
