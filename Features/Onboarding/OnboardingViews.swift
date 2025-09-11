import SwiftUI

struct SplashView: View {
    @EnvironmentObject var router: OnboardingRouter

    var body: some View {
        VStack(spacing: 24) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // boyutu istediğin gibi ayarlayabilirsin

            Button(action: { router.next() }) {
                Text("Continue with Game Center")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color("AccentBlue600"))
                    .cornerRadius(14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SurfaceLight"))
    }
}

struct NameView: View {
    @EnvironmentObject var router: OnboardingRouter
    @State private var stageName: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Stage Name")
                .font(.custom("Poppins-SemiBold", size: 28))
                .foregroundColor(Color("TextPrimary"))

            TextField("Stage name", text: $stageName)
                .textFieldStyle(.roundedBorder)
                .font(.custom("Poppins-Regular", size: 16))
                .padding(.horizontal)

            HStack(spacing: 24) {
                Button("Back") { router.back() }
                Button("Next") { router.next() }
                    .disabled(stageName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .font(.custom("Poppins-SemiBold", size: 18))
            .foregroundColor(Color("TextPrimary"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SurfaceLight"))
        .padding(.horizontal)
    }
}

struct AvatarView: View {
    @EnvironmentObject var router: OnboardingRouter
    @State private var selected: Int? = nil

    var body: some View {
        VStack(spacing: 24) {
            Text("Pick Your Avatar")
                .font(.custom("Poppins-SemiBold", size: 28))
                .foregroundColor(Color("TextPrimary"))

            HStack(spacing: 24) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(selected == i ? Color("AccentBlue600") : Color("IconTertiary"))
                        .frame(width: 64, height: 64)
                        .onTapGesture { selected = i }
                }
            }

            HStack(spacing: 24) {
                Button("Back") { router.back() }
                Button("Next") { router.next() }
                    .disabled(selected == nil)
            }
            .font(.custom("Poppins-SemiBold", size: 18))
            .foregroundColor(Color("TextPrimary"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SurfaceLight"))
        .padding(.horizontal)
    }
}

struct VibeView: View {
    @EnvironmentObject var router: OnboardingRouter
    @State private var vibeIndex: Int = 0
    private let vibes = ["Rock", "Pop", "Hip-Hop", "EDM"]

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Your Vibe")
                .font(.custom("Poppins-SemiBold", size: 28))
                .foregroundColor(Color("TextPrimary"))

            Picker("Vibe", selection: $vibeIndex) {
                ForEach(0..<vibes.count, id: \.self) { i in
                    Text(vibes[i]).tag(i)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            HStack(spacing: 24) {
                Button("Back") { router.back() }
                Button("Next") { router.next() }
            }
            .font(.custom("Poppins-SemiBold", size: 18))
            .foregroundColor(Color("TextPrimary"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SurfaceLight"))
        .padding(.horizontal)
    }
}

struct SummaryView: View {
    @EnvironmentObject var router: OnboardingRouter

    var body: some View {
        VStack(spacing: 24) {
            Text("You're Set!")
                .font(.custom("Poppins-SemiBold", size: 28))
                .foregroundColor(Color("TextPrimary"))

            Button(action: { /* finalize later */ }) {
                Text("Start Playing")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color("AccentBlue600"))
                    .cornerRadius(14)
            }

            Button("Back") { router.back() }
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SurfaceLight"))
        .padding(.horizontal)
    }
}

