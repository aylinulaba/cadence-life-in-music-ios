import SwiftUI
import CadenceCore
import CadenceUI

struct PublishReleaseView: View {
    let viewModel: GameStateViewModel
    @Binding var isPresented: Bool
    
    @State private var releaseTitle = ""
    @State private var releaseType: Release.ReleaseType = .single
    @State private var selectedRecordingIDs: Set<UUID> = []
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                releaseTitleSection
                releaseTypeSection
                recordingSelectionSection
                publishButtonSection
            }
            .navigationTitle("Publish Release")
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
    
    private var releaseTitleSection: some View {
        Section("Release Title") {
            TextField("Enter release title", text: $releaseTitle)
        }
    }
    
    private var releaseTypeSection: some View {
        Section("Release Type") {
            Picker("Type", selection: $releaseType) {
                ForEach([Release.ReleaseType.single, .album], id: \.self) { type in
                    HStack {
                        Text(type.emoji)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: releaseType) { oldValue, newValue in
                // Clear selection when changing type
                selectedRecordingIDs.removeAll()
            }
            
            Text("Minimum \(releaseType.minTracks) track\(releaseType.minTracks == 1 ? "" : "s") required")
                .font(.cadenceCaption)
                .foregroundStyle(Color.secondary)
        }
    }
    
    private var recordingSelectionSection: some View {
        Section("Select Recordings") {
            if unreleasedRecordings.isEmpty {
                Text("No recordings available. Record some songs first!")
                    .foregroundStyle(Color.secondary)
            } else {
                ForEach(unreleasedRecordings) { recording in
                    recordingRow(recording)
                }
                
                if selectedRecordingIDs.count < releaseType.minTracks {
                    Text("Select at least \(releaseType.minTracks) recording\(releaseType.minTracks == 1 ? "" : "s")")
                        .font(.cadenceCaption)
                        .foregroundStyle(Color.orange)
                }
            }
        }
    }
    
    private func recordingRow(_ recording: Recording) -> some View {
        Button(action: {
            if selectedRecordingIDs.contains(recording.id) {
                selectedRecordingIDs.remove(recording.id)
            } else {
                selectedRecordingIDs.insert(recording.id)
            }
        }) {
            HStack {
                Image(systemName: selectedRecordingIDs.contains(recording.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedRecordingIDs.contains(recording.id) ? Color.cadencePrimary : Color.secondary)
                
                if let song = viewModel.gameState.song(for: recording.songID) {
                    Text(song.genre.emoji)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.cadenceBody)
                            .foregroundStyle(Color.primary)
                        
                        HStack {
                            Text(recording.studioTier.rawValue)
                            Text("•")
                            Text("Quality: \(recording.quality)")
                        }
                        .font(.cadenceCaption)
                        .foregroundStyle(Color.secondary)
                    }
                } else {
                    Text("Unknown Song")
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var publishButtonSection: some View {
        Section {
            Button("Publish Release") {
                publishRelease()
            }
            .disabled(!canPublish)
        }
    }
    
    // MARK: - Computed Properties
    
    private var unreleasedRecordings: [Recording] {
        viewModel.unreleasedRecordings.sorted { $0.recordedAt > $1.recordedAt }
    }
    
    private var canPublish: Bool {
        !releaseTitle.isEmpty && selectedRecordingIDs.count >= releaseType.minTracks
    }
    
    // MARK: - Actions
    
    private func publishRelease() {
        do {
            try viewModel.publishRelease(
                title: releaseTitle,
                type: releaseType,
                recordingIDs: Array(selectedRecordingIDs)
            )
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
