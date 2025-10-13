import SwiftUI
import CadenceCore
import CadenceUI

struct OnboardingView: View {
    @State private var playerName = ""
    @State private var selectedGender: Player.Gender = .nonBinary
    @State private var selectedCity: City = .losAngeles
    
    let onComplete: (Player) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Text("🎵")
                        .font(.system(size: 80))
                    Text("Cadence: Life in Music")
                        .font(.cadenceTitle)
                        .multilineTextAlignment(.center)
                    Text("Create Your Character")
                        .font(.cadenceSubheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, Spacing.xxl)
                
                // Form
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Name Input
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Name")
                            .font(.cadenceBodyBold)
                        TextField("Enter your artist name", text: $playerName)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                    }
                    
                    // Gender Selection
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Gender")
                            .font(.cadenceBodyBold)
                        Picker("Gender", selection: $selectedGender) {
                            ForEach(Player.Gender.allCases, id: \.self) { gender in
                                Text(gender.displayName).tag(gender)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // City Selection
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Starting City")
                            .font(.cadenceBodyBold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.md) {
                                ForEach(City.allCities) { city in
                                    CityCard(
                                        city: city,
                                        isSelected: selectedCity.id == city.id
                                    )
                                    .onTapGesture {
                                        selectedCity = city
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                
                Spacer()
                
                // Start Button
                Button(action: createPlayer) {
                    Text("Start Your Journey")
                        .font(.cadenceBodyBold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Color.cadencePrimary)
                        .cornerRadius(12)
                }
                .disabled(playerName.count < 3)
                .opacity(playerName.count < 3 ? 0.5 : 1.0)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
        }
    }
    
    private func createPlayer() {
        let player = Player(
            name: playerName,
            gender: selectedGender,
            avatarID: "default",
            currentCityID: selectedCity.id
        )
        onComplete(player)
    }
}

// MARK: - City Card Component
struct CityCard: View {
    let city: City
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text(city.emoji)
                .font(.system(size: 48))
            
            Text(city.name)
                .font(.cadenceBodyBold)
                .foregroundStyle(isSelected ? .white : .primary)
            
            Text(city.country)
                .font(.cadenceCaption)
                .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .frame(width: 120, height: 140)
        .background(isSelected ? Color.cadencePrimary : Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.cadencePrimary : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    OnboardingView { player in
        print("Created player: \(player.name)")
    }
}
