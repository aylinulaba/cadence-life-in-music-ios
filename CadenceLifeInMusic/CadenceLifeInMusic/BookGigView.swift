import SwiftUI
import CadenceCore
import CadenceUI

struct BookGigView: View {
    let viewModel: GameStateViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedVenue: Venue?
    @State private var selectedSetlistID: UUID?
    @State private var scheduledDate = Date().addingTimeInterval(3600)
    @State private var ticketPrice: Double = 10.0
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                venueSelectionSection
                
                if selectedVenue != nil {
                    setlistSelectionSection
                    schedulingSection
                    ticketPricingSection
                    estimatesSection
                    bookButtonSection
                }
            }
            .navigationTitle("Book Gig")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var venueSelectionSection: some View {
        Section("Select Venue") {
            ForEach(availableVenues) { venue in
                venueButton(venue)
            }
        }
    }
    
    private func venueButton(_ venue: Venue) -> some View {
        Button(action: { selectedVenue = venue }) {
            HStack {
                let isSelected = selectedVenue?.id == venue.id
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.cadencePrimary : Color.secondary)
                
                Text(venue.venueType.emoji)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(venue.name)
                        .font(.cadenceBody)
                        .foregroundStyle(Color.primary)
                    
                    HStack {
                        Text("Capacity: \(venue.capacity)")
                        Text("•")
                        Text("Booking: $\(String(describing: venue.bookingCost))")
                    }
                    .font(.cadenceCaption)
                    .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                if viewModel.gameState.player.fame < venue.minFame {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color.red)
                }
            }
        }
        .disabled(viewModel.gameState.player.fame < venue.minFame)
    }
    
    private var setlistSelectionSection: some View {
        Section("Select Setlist") {
            if availableSetlists.isEmpty {
                Text("No setlists available. Create a setlist first!")
                    .foregroundStyle(Color.secondary)
            } else {
                Picker("Setlist", selection: $selectedSetlistID) {
                    Text("Select a setlist...").tag(nil as UUID?)
                    ForEach(availableSetlists) { setlist in
                        HStack {
                            Text(setlist.name)
                            Text("(Q: \(setlist.quality))")
                                .foregroundStyle(Color.secondary)
                        }
                        .tag(setlist.id as UUID?)
                    }
                }
            }
        }
    }
    
    private var schedulingSection: some View {
        Section("Schedule") {
            DatePicker(
                "Performance Date",
                selection: $scheduledDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }
    
    private var ticketPricingSection: some View {
        Section("Ticket Price") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("$\(Int(ticketPrice))")
                        .font(.cadenceBodyBold)
                    Spacer()
                }
                
                Slider(value: $ticketPrice, in: 5...50, step: 5)
                
                Text("Higher prices = lower attendance")
                    .font(.cadenceCaption)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
    
    private var estimatesSection: some View {
        Section("Estimates") {
            if let venue = selectedVenue {
                HStack {
                    Text("Booking Cost")
                    Spacer()
                    Text("$\(String(describing: venue.bookingCost))")
                        .foregroundStyle(canAfford ? Color.primary : Color.red)
                }
                
                HStack {
                    Text("Est. Attendance")
                    Spacer()
                    Text(String(estimatedAttendance))
                }
                
                HStack {
                    Text("Est. Revenue")
                    Spacer()
                    Text("$\(String(estimatedRevenue))")
                        .foregroundStyle(Color.green)
                }
                
                if !canAfford {
                    Text("⚠️ Not enough money for booking")
                        .font(.cadenceCaption)
                        .foregroundStyle(Color.red)
                }
            }
        }
    }
    
    private var bookButtonSection: some View {
        Section {
            Button("Book Gig") {
                bookGig()
            }
            .disabled(!canBook)
        }
    }
    
    private var availableVenues: [Venue] {
        let currentCity = viewModel.gameState.player.currentCityID
        return Venue.venues.filter { venue in
            venue.cityID == currentCity
        }
    }
    
    private var availableSetlists: [Setlist] {
        viewModel.setlists.filter { $0.isReady }
    }
    
    private var canAfford: Bool {
        guard let venue = selectedVenue else { return false }
        return viewModel.gameState.wallet.balance >= venue.bookingCost
    }
    
    private var canBook: Bool {
        selectedVenue != nil && selectedSetlistID != nil && canAfford
    }
    
    private var estimatedAttendance: Int {
        guard let venue = selectedVenue else { return 0 }
        let baseDraw = 20 + (viewModel.gameState.player.fame / 10)
        let fameMultiplier = 1.0 + (Double(viewModel.gameState.player.fame) / 1000.0)
        let priceRatio = ticketPrice / 20.0
        let priceSensitivity = 1.0 - (priceRatio * 0.3)
        let attendance = Int(Double(baseDraw) * fameMultiplier * priceSensitivity)
        return min(venue.capacity, max(0, attendance))
    }
    
    private var estimatedRevenue: Int {
        let gross = Int(Double(estimatedAttendance) * ticketPrice)
        let net = Int(Double(gross) * 0.7)
        return net
    }
    
    private func bookGig() {
        guard let venue = selectedVenue, let setlistID = selectedSetlistID else { return }
        
        do {
            try viewModel.bookGig(
                venue: venue,
                setlistID: setlistID,
                scheduledAt: scheduledDate,
                ticketPrice: Decimal(ticketPrice)
            )
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
