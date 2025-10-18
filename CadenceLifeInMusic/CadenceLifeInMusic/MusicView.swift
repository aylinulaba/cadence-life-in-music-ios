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

// MARK: - Activities Tab (Existing)
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

// MARK: - Placeholder Tabs (We'll implement these next)
struct SetlistsTabView: View {
    let viewModel: GameStateViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "music.note.list")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Setlists")
                    .font(.cadenceHeadline)
                Text("Coming in next update")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

struct RecordingsTabView: View {
    let viewModel: GameStateViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "waveform")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Recordings")
                    .font(.cadenceHeadline)
                Text("Coming in next update")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

struct ReleasesTabView: View {
    let viewModel: GameStateViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "optical.disc")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Releases")
                    .font(.cadenceHeadline)
                Text("Coming in next update")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
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
