import SwiftUI
import CadenceCore
import CadenceUI

struct MusicView: View {
    let viewModel: GameStateViewModel
    @State private var selectedTab: MusicTab = .activities
    
    enum MusicTab {
        case activities
        case songs
        case setlists
        case recordings
        case releases
        case gigs
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach([MusicTab.activities, .songs, .setlists, .recordings, .releases, .gigs], id: \.self) { tab in
                            TabButton(
                                title: tabTitle(for: tab),
                                isSelected: selectedTab == tab
                            ) {
                                selectedTab = tab
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
                .background(Color.cardBackground)
                
                Divider()
                
                // Content
                TabView(selection: $selectedTab) {
                    ActivitiesTabView(viewModel: viewModel)
                        .tag(MusicTab.activities)
                    
                    SongsTabView(viewModel: viewModel)
                        .tag(MusicTab.songs)
                    
                    SetlistsTabView(viewModel: viewModel)
                        .tag(MusicTab.setlists)
                    
                    RecordingsTabView(viewModel: viewModel)
                        .tag(MusicTab.recordings)
                    
                    ReleasesTabView(viewModel: viewModel)
                        .tag(MusicTab.releases)
                    
                    GigsTabView(viewModel: viewModel)
                        .tag(MusicTab.gigs)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Music")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func tabTitle(for tab: MusicTab) -> String {
        switch tab {
        case .activities: return "Activities"
        case .songs: return "Songs"
        case .setlists: return "Setlists"
        case .recordings: return "Recordings"
        case .releases: return "Releases"
        case .gigs: return "Gigs"
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.cadenceBody)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.cadencePrimary : Color.clear)
                .cornerRadius(8)
        }
    }
}

// MARK: - Activities Tab
struct ActivitiesTabView: View {
    let viewModel: GameStateViewModel
    @State private var showingActivityPicker = false
    @State private var selectedSlotType: TimeSlot.SlotType = .primaryFocus
    
    var primaryFocus: TimeSlot {
        viewModel.gameState.primaryFocus
    }
    
    var freeTime: TimeSlot {
        viewModel.gameState.freeTime
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                TimeSlotCard(
                    slot: primaryFocus,
                    onSetActivity: {
                        selectedSlotType = .primaryFocus
                        showingActivityPicker = true
                    },
                    onClearActivity: {
                        viewModel.clearActivity(in: .primaryFocus)
                    }
                )
                .id(viewModel.refreshTrigger)
                
                TimeSlotCard(
                    slot: freeTime,
                    onSetActivity: {
                        selectedSlotType = .freeTime
                        showingActivityPicker = true
                    },
                    onClearActivity: {
                        viewModel.clearActivity(in: .freeTime)
                    }
                )
                .id(viewModel.refreshTrigger)
                
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.cadencePrimary)
                        Text("How It Works")
                            .font(.cadenceBodyBold)
                    }
                    
                    Text("Choose activities for your Primary Focus and Free Time. Progress continues even when you're away!")
                        .font(.cadenceBody)
                        .foregroundStyle(.secondary)
                }
                .padding(Spacing.md)
                .background(Color.cardBackground)
                .cornerRadius(12)
            }
            .padding(Spacing.lg)
        }
        .sheet(isPresented: $showingActivityPicker) {
            ActivityPickerView(
                slotType: selectedSlotType,
                onSelect: { activity in
                    viewModel.setActivity(activity, in: selectedSlotType)
                    showingActivityPicker = false
                }
            )
        }
    }
}

// MARK: - Songs Tab
struct SongsTabView: View {
    let viewModel: GameStateViewModel
    @State private var showingCreateSong = false
    
    var songs: [Song] {
        viewModel.songs.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Create Song Button
                Button(action: { showingCreateSong = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Write New Song")
                    }
                    .font(.cadenceBodyBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.cadencePrimary)
                    .cornerRadius(12)
                }
                
                // Songs List
                if songs.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "music.note")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No Songs Yet")
                            .font(.cadenceHeadline)
                        Text("Write your first song to start your music career!")
                            .font(.cadenceBody)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Spacing.xl)
                } else {
                    ForEach(songs) { song in
                        SongCard(song: song, viewModel: viewModel)
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .sheet(isPresented: $showingCreateSong) {
            CreateSongView(viewModel: viewModel, isPresented: $showingCreateSong)
        }
    }
}

// MARK: - Song Card
struct SongCard: View {
    let song: Song
    let viewModel: GameStateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(song.genre.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.cadenceBodyBold)
                    
                    HStack {
                        Text(song.genre.rawValue)
                        Text("•")
                        Text(song.mood.rawValue)
                    }
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(song.qualityTier.rawValue)
                        .font(.cadenceCaption)
                        .foregroundStyle(.cadencePrimary)
                    
                    Text("\(song.quality)")
                        .font(.cadenceHeadline)
                        .foregroundStyle(.cadencePrimary)
                }
            }
            
            if song.isReleased {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Released")
                        .font(.cadenceCaption)
                }
            } else if song.recordingID != nil {
                HStack {
                    Image(systemName: "waveform.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Recorded")
                        .font(.cadenceCaption)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Create Song View
struct CreateSongView: View {
    let viewModel: GameStateViewModel
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var selectedGenre: Song.MusicGenre = .pop
    @State private var selectedMood: Song.SongMood = .upbeat
    @State private var selectedInstrument: Skill.SkillType = .guitar
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Song Details") {
                    TextField("Song Title", text: $title)
                    
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(Song.MusicGenre.allCases, id: \.self) { genre in
                            Text("\(genre.emoji) \(genre.rawValue)").tag(genre)
                        }
                    }
                    
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(Song.SongMood.allCases, id: \.self) { mood in
                            Text("\(mood.emoji) \(mood.rawValue)").tag(mood)
                        }
                    }
                }
                
                Section("Primary Instrument") {
                    Picker("Instrument", selection: $selectedInstrument) {
                        Text("🎸 Guitar").tag(Skill.SkillType.guitar)
                        Text("🎹 Piano").tag(Skill.SkillType.piano)
                        Text("🥁 Drums").tag(Skill.SkillType.drums)
                        Text("🎸 Bass").tag(Skill.SkillType.bass)
                    }
                }
                
                Section {
                    Button("Create Song") {
                        viewModel.createSong(
                            title: title,
                            genre: selectedGenre,
                            mood: selectedMood,
                            primaryInstrument: selectedInstrument
                        )
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Write New Song")
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
}

// MARK: - Setlists Tab
struct SetlistsTabView: View {
    let viewModel: GameStateViewModel
    @State private var showingCreateSetlist = false
    
    var setlists: [Setlist] {
        viewModel.setlists.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Create Setlist Button
                Button(action: { showingCreateSetlist = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Setlist")
                    }
                    .font(.cadenceBodyBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.cadencePrimary)
                    .cornerRadius(12)
                }
                
                // Setlists List
                if setlists.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No Setlists Yet")
                            .font(.cadenceHeadline)
                        Text("Create a setlist to prepare for gigs!")
                            .font(.cadenceBody)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Spacing.xl)
                } else {
                    ForEach(setlists) { setlist in
                        SetlistCard(setlist: setlist, viewModel: viewModel)
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .sheet(isPresented: $showingCreateSetlist) {
            CreateSetlistView(viewModel: viewModel, isPresented: $showingCreateSetlist)
        }
    }
}

// MARK: - Setlist Card
struct SetlistCard: View {
    let setlist: Setlist
    let viewModel: GameStateViewModel
    @State private var showingRehearsal = false
    
    var songs: [Song] {
        setlist.songIDs.compactMap { viewModel.gameState.song(for: $0) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setlist.name)
                        .font(.cadenceBodyBold)
                    
                    Text("\(setlist.songCount) songs")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Quality")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(setlist.quality)")
                        .font(.cadenceHeadline)
                        .foregroundStyle(qualityColor)
                }
            }
            
            // Readiness Status
            HStack {
                Image(systemName: setlist.isReady ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundStyle(setlist.isReady ? .green : .orange)
                
                Text(setlist.readinessStatus)
                    .font(.cadenceCaption)
            }
            
            // Rehearsal Info
            if setlist.rehearsalHours > 0 {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.blue)
                    Text("\(Int(setlist.rehearsalHours)) hours rehearsed")
                        .font(.cadenceCaption)
                }
            }
            
            Divider()
            
            // Songs Preview
            if !songs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Songs:")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    
                    ForEach(songs.prefix(3)) { song in
                        HStack(spacing: 4) {
                            Text(song.genre.emoji)
                            Text(song.title)
                                .font(.cadenceCaption)
                        }
                    }
                    
                    if songs.count > 3 {
                        Text("+ \(songs.count - 3) more")
                            .font(.cadenceCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Rehearse Button
            Button(action: { showingRehearsal = true }) {
                HStack {
                    Image(systemName: "figure.dance")
                    Text("Rehearse")
                }
                .font(.cadenceBodyBold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(Color.cadencePrimary)
                .cornerRadius(8)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .sheet(isPresented: $showingRehearsal) {
            RehearsalView(
                viewModel: viewModel,
                setlistID: setlist.id,
                isPresented: $showingRehearsal
            )
        }
    }
    
    private var qualityColor: Color {
        if setlist.quality >= 80 {
            return .green
        } else if setlist.quality >= 60 {
            return .blue
        } else if setlist.quality >= 40 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Create Setlist View
struct CreateSetlistView: View {
    let viewModel: GameStateViewModel
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var selectedSongIDs: Set<UUID> = []
    
    var availableSongs: [Song] {
        viewModel.unreleasedSongs
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Setlist Name") {
                    TextField("Enter setlist name", text: $name)
                }
                
                Section("Select Songs (min 3)") {
                    if availableSongs.isEmpty {
                        Text("No songs available. Write some songs first!")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableSongs) { song in
                            Button(action: {
                                if selectedSongIDs.contains(song.id) {
                                    selectedSongIDs.remove(song.id)
                                } else {
                                    selectedSongIDs.insert(song.id)
                                }
                            }) {
                                HStack {
                                    Image(systemName: selectedSongIDs.contains(song.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedSongIDs.contains(song.id) ? .cadencePrimary : .secondary)
                                    
                                    Text(song.genre.emoji)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(song.title)
                                            .font(.cadenceBody)
                                            .foregroundStyle(.primary)
                                        
                                        HStack {
                                            Text(song.genre.rawValue)
                                            Text("•")
                                            Text("Quality: \(song.quality)")
                                        }
                                        .font(.cadenceCaption)
                                        .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Create Setlist") {
                        viewModel.createSetlist(
                            name: name,
                            songIDs: Array(selectedSongIDs)
                        )
                        isPresented = false
                    }
                    .disabled(name.isEmpty || selectedSongIDs.count < 3)
                }
                
                if selectedSongIDs.count < 3 {
                    Section {
                        Text("Select at least 3 songs to create a setlist")
                            .font(.cadenceCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Create Setlist")
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
}

// MARK: - Rehearsal View
struct RehearsalView: View {
    let viewModel: GameStateViewModel
    let setlistID: UUID
    @Binding var isPresented: Bool
    
    @State private var rehearsalHours: Double = 1.0
    
    var setlist: Setlist? {
        viewModel.setlist(for: setlistID)
    }
    
    var cost: Decimal {
        0 // Rehearsal is free at home
    }
    
    var xpGain: Int {
        Int(rehearsalHours * 5)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Setlist") {
                    if let setlist = setlist {
                        HStack {
                            Text(setlist.name)
                                .font(.cadenceBodyBold)
                            Spacer()
                            Text("Quality: \(setlist.quality)")
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("\(setlist.songCount) songs • \(Int(setlist.rehearsalHours))h rehearsed")
                            .font(.cadenceCaption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Rehearsal Duration") {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("\(Int(rehearsalHours)) hour\(rehearsalHours == 1 ? "" : "s")")
                                .font(.cadenceBodyBold)
                            Spacer()
                        }
                        
                        Slider(value: $rehearsalHours, in: 1...8, step: 1)
                    }
                }
                
                Section("Benefits") {
                    HStack {
                        Text("Setlist Quality")
                        Spacer()
                        Text("+\(Int(rehearsalHours * 10)) (up to +40 max)")
                            .foregroundStyle(.green)
                    }
                    
                    HStack {
                        Text("Performance XP")
                        Spacer()
                        Text("+\(xpGain)")
                            .foregroundStyle(.blue)
                    }
                    
                    HStack {
                        Text("Cost")
                        Spacer()
                        Text("Free")
                            .foregroundStyle(.green)
                    }
                }
                
                Section {
                    Button("Start Rehearsal") {
                        viewModel.rehearseSetlist(
                            setlistID: setlistID,
                            hours: rehearsalHours
                        )
                        isPresented = false
                    }
                }
            }
            .navigationTitle("Rehearse")
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
}

// MARK: - Recordings Tab
struct RecordingsTabView: View {
    let viewModel: GameStateViewModel
    @State private var showingRecordSong = false
    
    var recordings: [Recording] {
        viewModel.recordings.sorted { $0.recordedAt > $1.recordedAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Record Song Button
                Button(action: { showingRecordSong = true }) {
                    HStack {
                        Image(systemName: "waveform.circle.fill")
                        Text("Record Song")
                    }
                    .font(.cadenceBodyBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.cadencePrimary)
                    .cornerRadius(12)
                }
                
                // Recordings List
                if recordings.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "waveform")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No Recordings Yet")
                            .font(.cadenceHeadline)
                        Text("Record your songs to release them!")
                            .font(.cadenceBody)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Spacing.xl)
                } else {
                    ForEach(recordings) { recording in
                        RecordingCard(recording: recording, viewModel: viewModel)
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .sheet(isPresented: $showingRecordSong) {
            RecordSongView(viewModel: viewModel, isPresented: $showingRecordSong)
        }
    }
}

// MARK: - Recording Card
struct RecordingCard: View {
    let recording: Recording
    let viewModel: GameStateViewModel
    
    var song: Song? {
        viewModel.gameState.song(for: recording.songID)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                Text(recording.studioTier.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let song = song {
                        Text(song.title)
                            .font(.cadenceBodyBold)
                        
                        HStack {
                            Text(song.genre.rawValue)
                            Text("•")
                            Text(recording.studioTier.rawValue)
                        }
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    } else {
                        Text("Unknown Song")
                            .font(.cadenceBodyBold)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Quality")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(recording.quality)")
                        .font(.cadenceHeadline)
                        .foregroundStyle(qualityColor(recording.quality))
                }
            }
            
            // Status
            HStack {
                if recording.isReleased {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Released")
                        .font(.cadenceCaption)
                } else {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.blue)
                    Text("Ready to release")
                        .font(.cadenceCaption)
                }
            }
            
            // Date
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text("Recorded \(recording.recordedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func qualityColor(_ quality: Int) -> Color {
        if quality >= 80 {
            return .green
        } else if quality >= 60 {
            return .blue
        } else if quality >= 40 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Releases Tab
struct ReleasesTabView: View {
    let viewModel: GameStateViewModel
    @State private var showingPublishRelease = false
    
    var releases: [Release] {
        viewModel.releases.sorted { $0.releasedAt > $1.releasedAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Publish Release Button
                Button(action: { showingPublishRelease = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Publish Release")
                    }
                    .font(.cadenceBodyBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.cadencePrimary)
                    .cornerRadius(12)
                }
                
                // Releases List
                if releases.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "optical.disc")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No Releases Yet")
                            .font(.cadenceHeadline)
                        Text("Publish your recordings as singles or albums!")
                            .font(.cadenceBody)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Spacing.xl)
                } else {
                    ForEach(releases) { release in
                        ReleaseCard(release: release, viewModel: viewModel)
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .sheet(isPresented: $showingPublishRelease) {
            PublishReleaseView(viewModel: viewModel, isPresented: $showingPublishRelease)
        }
    }
}

// MARK: - Release Card
struct ReleaseCard: View {
    let release: Release
    let viewModel: GameStateViewModel
    
    var recordings: [Recording] {
        release.recordingIDs.compactMap { viewModel.gameState.recording(for: $0) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                Text(release.type.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(release.title)
                        .font(.cadenceBodyBold)
                    
                    HStack {
                        Text(release.type.rawValue)
                        Text("•")
                        Text("\(recordings.count) track\(recordings.count == 1 ? "" : "s")")
                    }
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Stats
            HStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Plays")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    Text("\(release.totalPlays)")
                        .font(.cadenceBodyBold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Revenue")
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    Text("$\(release.totalRevenue)")
                        .font(.cadenceBodyBold)
                        .foregroundStyle(.green)
                }
                
                Spacer()
            }
            
            // Release Date
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text("Released \(release.releasedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct GigsTabView: View {
    let viewModel: GameStateViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "music.mic")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Gigs")
                    .font(.cadenceHeadline)
                Text("Coming in next update")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    let player = Player(
        name: "Demo Artist",
        gender: .nonBinary,
        avatarID: "default",
        currentCityID: City.losAngeles.id
    )
    let gameState = GameState.new(player: player)
    let viewModel = GameStateViewModel(gameState: gameState)
    
    return MusicView(viewModel: viewModel)
}
