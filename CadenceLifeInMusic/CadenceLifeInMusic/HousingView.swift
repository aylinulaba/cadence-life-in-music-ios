import SwiftUI
import CadenceCore
import CadenceUI

struct HousingView: View {
    let viewModel: GameStateViewModel
    @State private var showingUpgradeSheet = false
    @State private var showingPayRentSheet = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var currentHousing: Housing? {
        viewModel.gameState.currentHousing
    }
    
    var currentCity: City? {
        viewModel.gameState.currentCity
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    if let housing = currentHousing, let city = currentCity {
                        // Current Housing Card
                        CurrentHousingCard(
                            housing: housing,
                            city: city,
                            onPayRent: { showingPayRentSheet = true },
                            onUpgrade: { showingUpgradeSheet = true }
                        )
                        
                        // Rent Status
                        RentStatusCard(housing: housing, city: city)
                        
                        // Housing Benefits
                        BenefitsCard(housing: housing)
                        
                        // Available Upgrades
                        if canUpgrade(from: housing.housingType) {
                            UpgradesSection(
                                currentType: housing.housingType,
                                city: city,
                                onSelect: { showingUpgradeSheet = true }
                            )
                        }
                    } else {
                        EmptyHousingView()
                    }
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Housing")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingUpgradeSheet) {
                if let housing = currentHousing, let city = currentCity {
                    UpgradeHousingSheet(
                        viewModel: viewModel,
                        currentHousing: housing,
                        city: city,
                        isPresented: $showingUpgradeSheet,
                        onError: { message in
                            errorMessage = message
                            showingError = true
                        }
                    )
                }
            }
            .sheet(isPresented: $showingPayRentSheet) {
                if let housing = currentHousing, let city = currentCity {
                    PayRentSheet(
                        viewModel: viewModel,
                        housing: housing,
                        city: city,
                        isPresented: $showingPayRentSheet,
                        onError: { message in
                            errorMessage = message
                            showingError = true
                        }
                    )
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func canUpgrade(from type: Housing.HousingType) -> Bool {
        type != .penthouse
    }
}

// MARK: - Current Housing Card

struct CurrentHousingCard: View {
    let housing: Housing
    let city: City
    let onPayRent: () -> Void
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(housing.housingType.emoji)
                    .font(.system(size: 60))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(housing.housingType.displayName)
                        .font(.cadenceTitle)
                    
                    Text(city.name)
                        .font(.cadenceBody)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Text(housing.housingType.description)
                .font(.cadenceBody)
                .foregroundStyle(.secondary)
            
            Divider()
            
            HStack {
                Button(action: onPayRent) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("Pay Rent")
                    }
                    .font(.cadenceBodyBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                
                if housing.housingType != .penthouse {
                    Button(action: onUpgrade) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                            Text("Upgrade")
                        }
                        .font(.cadenceBodyBold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.cadencePrimary)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Rent Status Card

struct RentStatusCard: View {
    let housing: Housing
    let city: City
    
    var statusColor: Color {
        if housing.isAtRiskOfEviction {
            return Color.red
        } else if housing.isRentOverdue {
            return Color.orange
        } else if housing.isRentDueSoon {
            return Color.yellow
        } else {
            return Color.green
        }
    }
    
    var statusIcon: String {
        if housing.isAtRiskOfEviction {
            return "exclamationmark.triangle.fill"
        } else if housing.isRentOverdue {
            return "exclamationmark.circle.fill"
        } else if housing.isRentDueSoon {
            return "clock.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    var statusMessage: String {
        if housing.isAtRiskOfEviction {
            return "EVICTION WARNING! \(housing.daysOverdue) days overdue"
        } else if housing.isRentOverdue {
            return "Rent overdue by \(housing.daysOverdue) day\(housing.daysOverdue == 1 ? "" : "s")"
        } else if housing.isRentDueSoon {
            return "Rent due in \(housing.daysUntilRentDue) day\(housing.daysUntilRentDue == 1 ? "" : "s")"
        } else {
            return "Rent paid until \(housing.rentPaidUntil.formatted(date: .abbreviated, time: .omitted))"
        }
    }
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rent Status")
                        .font(.cadenceBodyBold)
                    
                    Text(statusMessage)
                        .font(.cadenceBody)
                        .foregroundStyle(statusColor)
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Rent")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    Text("$\(formatDecimal(housing.weeklyRent(in: city)))")
                        .font(.cadenceBodyBold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Next Payment")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    Text(housing.rentPaidUntil.formatted(date: .abbreviated, time: .omitted))
                        .font(.cadenceBody)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

// MARK: - Benefits Card

struct BenefitsCard: View {
    let housing: Housing
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Benefits")
                .font(.cadenceHeadline)
            
            VStack(spacing: Spacing.sm) {
                BenefitRow(
                    icon: "bed.double.fill",
                    title: "Rest Quality",
                    value: "+\(Int((housing.housingType.restQualityMultiplier - 1.0) * 100))%",
                    color: Color.blue
                )
                
                BenefitRow(
                    icon: "shippingbox.fill",
                    title: "Storage Slots",
                    value: "\(housing.housingType.storageSlots)",
                    color: Color.orange
                )
                
                BenefitRow(
                    icon: "star.fill",
                    title: "Reputation Bonus",
                    value: "+\(housing.housingType.reputationBonus)",
                    color: Color.purple
                )
                
                if housing.housingType.allowsHomeRecording {
                    BenefitRow(
                        icon: "waveform",
                        title: "Home Recording",
                        value: "Up to \(housing.housingType.homeRecordingQualityCap) quality",
                        color: Color.green
                    )
                }
                
                if housing.housingType.passiveMoodBonus > 0 {
                    BenefitRow(
                        icon: "face.smiling.fill",
                        title: "Daily Mood Bonus",
                        value: "+\(housing.housingType.passiveMoodBonus)",
                        color: Color.yellow
                    )
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30)
            
            Text(title)
                .font(.cadenceBody)
            
            Spacer()
            
            Text(value)
                .font(.cadenceBodyBold)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Upgrades Section

struct UpgradesSection: View {
    let currentType: Housing.HousingType
    let city: City
    let onSelect: () -> Void
    
    var availableUpgrades: [Housing.HousingType] {
        let allTypes = Housing.HousingType.allCases
        guard let currentIndex = allTypes.firstIndex(of: currentType) else { return [] }
        return Array(allTypes.dropFirst(currentIndex + 1))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Available Upgrades")
                .font(.cadenceHeadline)
                .padding(.horizontal, Spacing.md)
            
            VStack(spacing: Spacing.sm) {
                ForEach(availableUpgrades, id: \.self) { type in
                    UpgradeOptionCard(housingType: type, city: city, onSelect: onSelect)
                }
            }
        }
    }
}

struct UpgradeOptionCard: View {
    let housingType: Housing.HousingType
    let city: City
    let onSelect: () -> Void
    
    var weeklyRent: Decimal {
        housingType.baseWeeklyRent * city.housingCostMultiplier
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.md) {
                Text(housingType.emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(housingType.displayName)
                        .font(.cadenceBodyBold)
                        .foregroundStyle(.primary)
                    
                    Text("$\(formatDecimal(weeklyRent))/week")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

// MARK: - Upgrade Housing Sheet

struct UpgradeHousingSheet: View {
    let viewModel: GameStateViewModel
    let currentHousing: Housing
    let city: City
    @Binding var isPresented: Bool
    let onError: (String) -> Void
    
    @State private var selectedType: Housing.HousingType?
    
    var availableUpgrades: [Housing.HousingType] {
        let allTypes = Housing.HousingType.allCases
        guard let currentIndex = allTypes.firstIndex(of: currentHousing.housingType) else { return [] }
        return Array(allTypes.dropFirst(currentIndex + 1))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableUpgrades, id: \.self) { type in
                    UpgradeDetailRow(
                        housingType: type,
                        currentHousing: currentHousing,
                        city: city,
                        isSelected: selectedType == type,
                        onSelect: { selectedType = type }
                    )
                }
                
                if let selected = selectedType {
                    Section {
                        Button("Confirm Upgrade") {
                            upgradeHousing(to: selected)
                        }
                        .disabled(viewModel.gameState.wallet.balance < proratedCost(for: selected))
                    }
                }
            }
            .navigationTitle("Upgrade Housing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func proratedCost(for newType: Housing.HousingType) -> Decimal {
        let oldWeeklyRent = currentHousing.housingType.baseWeeklyRent * city.housingCostMultiplier
        let newWeeklyRent = newType.baseWeeklyRent * city.housingCostMultiplier
        let rentDifference = newWeeklyRent - oldWeeklyRent
        let daysLeft = currentHousing.daysUntilRentDue
        return (rentDifference / 7) * Decimal(daysLeft)
    }
    
    private func upgradeHousing(to newType: Housing.HousingType) {
        do {
            try viewModel.upgradeHousing(newHousingType: newType)
            isPresented = false
        } catch {
            onError(error.localizedDescription)
        }
    }
}

struct UpgradeDetailRow: View {
    let housingType: Housing.HousingType
    let currentHousing: Housing
    let city: City
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.cadencePrimary : Color.secondary)
                
                Text(housingType.emoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(housingType.displayName)
                        .font(.cadenceBody)
                        .foregroundStyle(.primary)
                    
                    Text("$\(formatDecimal(housingType.baseWeeklyRent * city.housingCostMultiplier))/week")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

// MARK: - Pay Rent Sheet

struct PayRentSheet: View {
    let viewModel: GameStateViewModel
    let housing: Housing
    let city: City
    @Binding var isPresented: Bool
    let onError: (String) -> Void
    
    @State private var weeksCount: Int = 1
    
    var totalCost: Decimal {
        housing.weeklyRent(in: city) * Decimal(weeksCount)
    }
    
    var canAfford: Bool {
        viewModel.gameState.wallet.balance >= totalCost
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Payment Details") {
                    HStack {
                        Text("Weekly Rent")
                        Spacer()
                        Text("$\(formatDecimal(housing.weeklyRent(in: city)))")
                    }
                    
                    Stepper("Weeks: \(weeksCount)", value: $weeksCount, in: 1...12)
                    
                    HStack {
                        Text("Total Cost")
                        Spacer()
                        Text("$\(formatDecimal(totalCost))")
                            .foregroundStyle(canAfford ? .primary : Color.red)
                            .font(.cadenceBodyBold)
                    }
                    
                    if !canAfford {
                        Text("⚠️ Not enough money")
                            .font(.cadenceCaption)
                            .foregroundStyle(Color.red)
                    }
                }
                
                Section {
                    Button("Pay Rent") {
                        payRent()
                    }
                    .disabled(!canAfford)
                }
            }
            .navigationTitle("Pay Rent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func payRent() {
        do {
            try viewModel.payRent(weeksCount: weeksCount)
            isPresented = false
        } catch {
            onError(error.localizedDescription)
        }
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

// MARK: - Empty Housing View

struct EmptyHousingView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "house.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Housing")
                .font(.cadenceHeadline)
            
            Text("You don't have any housing yet.")
                .font(.cadenceBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xl)
    }
}

#Preview {
    let player = Player(
        name: "Demo Artist",
        gender: .nonBinary,
        avatarID: "default",
        currentCityID: City.losAngeles.id
    )
    var gameState = GameState.new(player: player)
    gameState.currentHousing = Housing(
        playerID: player.id,
        housingType: .oneBedroom,
        cityID: City.losAngeles.id
    )
    let viewModel = GameStateViewModel(gameState: gameState)
    
    return HousingView(viewModel: viewModel)
}
