import SwiftUI
import CadenceCore
import CadenceUI

struct RecordSongView: View {
    let viewModel: GameStateViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedSongID: UUID?
    @State private var selectedStudioTier: Recording.StudioTier = .basic
    @State private var recordingHours: Int = 2
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                songSelectionSection
                
                if selectedSong != nil {
                    studioTierSection
                    recordingDurationSection
                    estimatedResultsSection
                    recordButtonSection
                }
            }
            .navigationTitle("Record Song")
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
    
    // MARK: - Sections
    
    private var songSelectionSection: some View {
        Section("Select Song") {
            if unrecordedSongs.isEmpty {
                Text("No songs available to record. All songs have been recorded!")
                    .foregroundStyle(Color.secondary)
            } else {
                Picker("Song", selection: $selectedSongID) {
                    Text("Select a song...").tag(nil as UUID?)
                    ForEach(unrecordedSongs) { song in
                        songPickerRow(song)
                    }
                }
            }
        }
    }
    
    private func songPickerRow(_ song: Song) -> some View {
        HStack {
            Text(song.genre.emoji)
            Text(song.title)
            Text("(Q: \(song.quality))")
                .foregroundStyle(Color.secondary)
        }
        .tag(song.id as UUID?)
    }
    
    private var studioTierSection: some View {
        Section("Studio Tier") {
            ForEach(Recording.StudioTier.allCases, id: \.self) { tier in
                studioTierButton(tier)
            }
        }
    }
    
    private func studioTierButton(_ tier: Recording.StudioTier) -> some View {
        Button(action: { selectedStudioTier = tier }) {
            HStack {
                Image(systemName: selectedStudioTier == tier ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedStudioTier == tier ? Color.cadencePrimary : Color.secondary)
                
                Text(tier.emoji)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(tier.rawValue)
                        .font(.cadenceBody)
                        .foregroundStyle(Color.primary)
                    
                    Text("$\(tier.hourlyRate)/hour • Max Quality: \(tier.qualityCap)")
                        .font(.cadenceCaption)
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var recordingDurationSection: some View {
        Section("Recording Duration") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("\(recordingHours) hour\(recordingHours == 1 ? "" : "s")")
                        .font(.cadenceBodyBold)
                    Spacer()
                    Text("$\(totalCost)")
                        .font(.cadenceBodyBold)
                        .foregroundStyle(canAfford ? Color.primary : Color.red)
                }
                
                Stepper("", value: $recordingHours, in: 1...8)
                    .labelsHidden()
            }
        }
    }
    
    private var estimatedResultsSection: some View {
        Section("Estimated Results") {
            HStack {
                Text("Recording Quality")
                Spacer()
                Text("\(estimatedQuality)")
                    .foregroundStyle(Color.cadencePrimary)
            }
            
            HStack {
                Text("Production XP")
                Spacer()
                Text("+\(recordingHours * 10)")
                    .foregroundStyle(Color.blue)
            }
            
            HStack {
                Text("Total Cost")
                Spacer()
                Text("$\(totalCost)")
                    .foregroundStyle(canAfford ? Color.primary : Color.red)
            }
            
            if !canAfford {
                Text("⚠️ Not enough money")
                    .font(.cadenceCaption)
                    .foregroundStyle(Color.red)
            }
        }
    }
    
    private var recordButtonSection: some View {
        Section {
            Button("Record Song") {
                recordSong()
            }
            .disabled(selectedSongID == nil || !canAfford)
        }
    }
    
    // MARK: - Computed Properties
    
    private var unrecordedSongs: [Song] {
        viewModel.songs.filter { $0.recordingID == nil }
    }
    
    private var selectedSong: Song? {
        guard let id = selectedSongID else { return nil }
        return viewModel.gameState.song(for: id)
    }
    
    private var totalCost: Decimal {
        Decimal(selectedStudioTier.hourlyRate * recordingHours)
    }
    
    private var canAfford: Bool {
        viewModel.gameState.wallet.balance >= totalCost
    }
    
    private var estimatedQuality: Int {
        guard let song = selectedSong else { return 0 }
        let performanceSkill = viewModel.skill(for: .performance)?.currentLevel ?? 0
        let productionSkill = viewModel.skill(for: .production)?.currentLevel ?? 0
        
        let songQuality: Double = Double(song.quality)
        let perfSkill: Double = Double(performanceSkill)
        let prodSkill: Double = Double(productionSkill)
        let studioCap: Double = Double(selectedStudioTier.qualityCap)
        
        let songComp: Double = songQuality * 0.4
        let perfComp: Double = perfSkill * 0.3
        let prodComp: Double = prodSkill * 0.2
        let studioBonus: Double = studioCap * 0.1
        
        let total: Double = songComp + perfComp + prodComp + studioBonus
        let result: Int = Int(total)
        
        return min(selectedStudioTier.qualityCap, result)
    }
    
    // MARK: - Actions
    
    private func recordSong() {
        guard let songID = selectedSongID else { return }
        
        do {
            try viewModel.recordSong(
                songID: songID,
                studioTier: selectedStudioTier,
                hours: recordingHours
            )
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
