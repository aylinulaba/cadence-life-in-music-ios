import SwiftUI
import CadenceCore
import CadenceUI

struct EquipmentShopView: View {
    let viewModel: GameStateViewModel
    @State private var selectedTab: EquipmentTab = .shop
    @State private var selectedType: Equipment.EquipmentType = .guitar
    @State private var showingPurchaseConfirmation = false
    @State private var selectedCatalogItem: EquipmentCatalogItem?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    enum EquipmentTab {
        case shop
        case inventory
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                HStack(spacing: Spacing.sm) {
                    TabButton(
                        title: "Shop",
                        isSelected: selectedTab == .shop
                    ) {
                        selectedTab = .shop
                    }
                    
                    TabButton(
                        title: "My Equipment",
                        isSelected: selectedTab == .inventory
                    ) {
                        selectedTab = .inventory
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.cardBackground)
                
                Divider()
                
                // Content
                if selectedTab == .shop {
                    ShopTabView(
                        viewModel: viewModel,
                        selectedType: $selectedType,
                        selectedCatalogItem: $selectedCatalogItem,
                        showingPurchaseConfirmation: $showingPurchaseConfirmation
                    )
                } else {
                    InventoryTabView(
                        viewModel: viewModel,
                        onRepair: { equipmentID in
                            repairEquipment(equipmentID)
                        },
                        onSell: { equipmentID in
                            sellEquipment(equipmentID)
                        }
                    )
                }
            }
            .navigationTitle("Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Purchase Equipment", isPresented: $showingPurchaseConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Purchase") {
                    purchaseEquipment()
                }
            } message: {
                if let item = selectedCatalogItem {
                    Text("Purchase \(item.name) for $\(formatDecimal(item.price))?")
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func purchaseEquipment() {
        guard let item = selectedCatalogItem else { return }
        
        do {
            try viewModel.purchaseEquipment(catalogItem: item)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func repairEquipment(_ equipmentID: UUID) {
        do {
            try viewModel.repairEquipment(equipmentID: equipmentID)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func sellEquipment(_ equipmentID: UUID) {
        do {
            try viewModel.sellEquipment(equipmentID: equipmentID)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
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

// MARK: - Shop Tab

struct ShopTabView: View {
    let viewModel: GameStateViewModel
    @Binding var selectedType: Equipment.EquipmentType
    @Binding var selectedCatalogItem: EquipmentCatalogItem?
    @Binding var showingPurchaseConfirmation: Bool
    
    var catalogItems: [EquipmentCatalogItem] {
        Equipment.catalogItems(for: selectedType)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Wallet Balance
                WalletBalanceCard(balance: viewModel.gameState.wallet.balance)
                
                // Equipment Type Selector
                EquipmentTypeSelector(selectedType: $selectedType)
                
                // Shop Items
                VStack(spacing: Spacing.sm) {
                    ForEach(catalogItems) { item in
                        ShopItemCard(
                            item: item,
                            canAfford: viewModel.gameState.wallet.balance >= item.price,
                            alreadyOwns: viewModel.ownsEquipment(ofType: item.equipmentType),
                            onPurchase: {
                                selectedCatalogItem = item
                                showingPurchaseConfirmation = true
                            }
                        )
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
}

// MARK: - Inventory Tab

struct InventoryTabView: View {
    let viewModel: GameStateViewModel
    let onRepair: (UUID) -> Void
    let onSell: (UUID) -> Void
    @State private var showingSellConfirmation = false
    @State private var equipmentToSell: Equipment?
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Inventory Stats
                InventoryStatsCard(
                    itemCount: viewModel.equipmentInventory.count,
                    totalValue: viewModel.totalInventoryValue,
                    needsRepair: viewModel.equipmentNeedingRepair.count
                )
                
                // Equipment List
                if viewModel.equipmentInventory.isEmpty {
                    EmptyInventoryView()
                } else {
                    VStack(spacing: Spacing.sm) {
                        ForEach(viewModel.equipmentInventory) { equipment in
                            InventoryItemCard(
                                equipment: equipment,
                                onRepair: { onRepair(equipment.id) },
                                onSell: {
                                    equipmentToSell = equipment
                                    showingSellConfirmation = true
                                }
                            )
                        }
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .alert("Sell Equipment", isPresented: $showingSellConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sell", role: .destructive) {
                if let equipment = equipmentToSell {
                    onSell(equipment.id)
                }
            }
        } message: {
            if let equipment = equipmentToSell {
                let durabilityMultiplier = Decimal(equipment.durability) / 100
                let sellPrice = equipment.basePrice * 0.5 * durabilityMultiplier
                Text("Sell \(equipment.name) for $\(formatDecimal(sellPrice))?")
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

// MARK: - Supporting Components

struct WalletBalanceCard: View {
    let balance: Decimal
    
    var body: some View {
        HStack {
            Image(systemName: "dollarsign.circle.fill")
                .foregroundStyle(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Balance")
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
                
                Text("$\(formatDecimal(balance))")
                    .font(.cadenceHeadline)
                    .foregroundStyle(.green)
            }
            
            Spacer()
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

struct EquipmentTypeSelector: View {
    @Binding var selectedType: Equipment.EquipmentType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(Equipment.EquipmentType.allCases, id: \.self) { type in
                    Button(action: { selectedType = type }) {
                        VStack(spacing: 4) {
                            Text(type.emoji)
                                .font(.title2)
                            Text(type.displayName)
                                .font(.cadenceCaption)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(selectedType == type ? Color.cadencePrimary : Color.cardBackground)
                        .foregroundStyle(selectedType == type ? .white : .primary)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct ShopItemCard: View {
    let item: EquipmentCatalogItem
    let canAfford: Bool
    let alreadyOwns: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(item.equipmentType.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.cadenceBodyBold)
                    
                    Text(item.tier.displayName)
                        .font(.cadenceCaption)
                        .foregroundStyle(tierColor(item.tier))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(formatDecimal(item.price))")
                        .font(.cadenceHeadline)
                        .foregroundStyle(canAfford ? .green : .red)
                    
                    Text("+\(Int((item.tier.bonusMultiplier - 1.0) * 100))% bonus")
                        .font(.cadenceCaption)
                        .foregroundStyle(.blue)
                }
            }
            
            if alreadyOwns {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Already owned")
                        .font(.cadenceCaption)
                        .foregroundStyle(.green)
                }
            }
            
            Button(action: onPurchase) {
                Text("Purchase")
                    .font(.cadenceBodyBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(canAfford ? Color.cadencePrimary : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!canAfford)
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func tierColor(_ tier: Equipment.EquipmentTier) -> Color {
        switch tier {
        case .basic: return .gray
        case .professional: return .blue
        case .legendary: return .purple
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

struct InventoryStatsCard: View {
    let itemCount: Int
    let totalValue: Decimal
    let needsRepair: Int
    
    var body: some View {
        HStack(spacing: Spacing.lg) {
            StatBadge(icon: "bag.fill", value: "\(itemCount)", label: "Items")
            StatBadge(icon: "dollarsign.circle.fill", value: "$\(formatDecimal(totalValue))", label: "Value")
            StatBadge(icon: "wrench.fill", value: "\(needsRepair)", label: "Need Repair")
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: nsDecimal) ?? "0"
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.cadencePrimary)
            Text(value)
                .font(.cadenceBodyBold)
            Text(label)
                .font(.cadenceCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct InventoryItemCard: View {
    let equipment: Equipment
    let onRepair: () -> Void
    let onSell: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(equipment.equipmentType.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(equipment.name)
                        .font(.cadenceBodyBold)
                    
                    Text(equipment.tier.displayName)
                        .font(.cadenceCaption)
                        .foregroundStyle(tierColor(equipment.tier))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(equipment.durability)%")
                        .font(.cadenceHeadline)
                        .foregroundStyle(durabilityColor(equipment.durability))
                    
                    Text("+\(Int((equipment.performanceBonus - 1.0) * 100))%")
                        .font(.cadenceCaption)
                        .foregroundStyle(.blue)
                }
            }
            
            // Durability Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(durabilityColor(equipment.durability))
                        .frame(width: geometry.size.width * (Double(equipment.durability) / 100.0))
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            // Action Buttons
            HStack(spacing: Spacing.sm) {
                if equipment.needsRepair {
                    Button(action: onRepair) {
                        HStack {
                            Image(systemName: "wrench.fill")
                            Text("Repair ($\(formatDecimal(equipment.repairCost)))")
                        }
                        .font(.cadenceCaption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.orange)
                        .cornerRadius(6)
                    }
                }
                
                Button(action: onSell) {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                        Text("Sell")
                    }
                    .font(.cadenceCaption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.red)
                    .cornerRadius(6)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func tierColor(_ tier: Equipment.EquipmentTier) -> Color {
        switch tier {
        case .basic: return .gray
        case .professional: return .blue
        case .legendary: return .purple
        }
    }
    
    private func durabilityColor(_ durability: Int) -> Color {
        switch durability {
        case 0..<25: return .red
        case 25..<50: return .orange
        case 50..<75: return .yellow
        default: return .green
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

struct EmptyInventoryView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "bag.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Equipment Yet")
                .font(.cadenceHeadline)
            
            Text("Visit the shop to purchase your first instrument!")
                .font(.cadenceBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Preview

#Preview {
    let player = Player(
        name: "Demo Artist",
        gender: .nonBinary,
        avatarID: "default",
        currentCityID: City.losAngeles.id
    )
    let gameState = GameState.new(player: player)
    let viewModel = GameStateViewModel(gameState: gameState)
    
    return EquipmentShopView(viewModel: viewModel)
}
