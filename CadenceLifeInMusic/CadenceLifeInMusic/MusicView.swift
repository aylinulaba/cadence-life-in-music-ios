import SwiftUI
import CadenceCore
import CadenceUI

struct MusicView: View {
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
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Primary Focus Slot
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
                    
                    // Free Time Slot
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
                    
                    // Info Card
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
            .navigationTitle("Music")
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
}

// MARK: - Time Slot Card
struct TimeSlotCard: View {
    let slot: TimeSlot
    let onSetActivity: () -> Void
    let onClearActivity: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Image(systemName: slotIcon)
                    .foregroundStyle(.cadencePrimary)
                Text(slot.slotType.displayName)
                    .font(.cadenceHeadline)
                Spacer()
            }
            
            Text(slot.slotType.description)
                .font(.cadenceCaption)
                .foregroundStyle(.secondary)
            
            Divider()
            
            // Current Activity
            if let activity = slot.currentActivity {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Image(systemName: activity.type.icon)
                            .foregroundStyle(.cadenceAccent)
                        Text(activity.name)
                            .font(.cadenceBodyBold)
                        Spacer()
                        Text(slot.formattedElapsedTime)
                            .font(.cadenceCaption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(activity.description)
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                    
                    Button(action: onClearActivity) {
                        Text("Stop Activity")
                            .font(.cadenceBody)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            } else {
                Button(action: onSetActivity) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Set Activity")
                    }
                    .font(.cadenceBody)
                    .foregroundStyle(.cadencePrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.cadencePrimary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private var slotIcon: String {
        switch slot.slotType {
        case .primaryFocus: return "star.fill"
        case .freeTime: return "clock.fill"
        }
    }
}

// MARK: - Activity Picker
struct ActivityPickerView: View {
    let slotType: TimeSlot.SlotType
    let onSelect: (Activity) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Practice Instruments") {
                    ForEach([Skill.SkillType.guitar, .piano, .drums, .bass], id: \.self) { instrument in
                        let activity = Activity.practice(instrument: instrument)
                        ActivityPickerRow(activity: activity)
                            .onTapGesture {
                                onSelect(activity)
                            }
                    }
                }
                
                Section("Recovery") {
                    ActivityPickerRow(activity: .rest)
                        .onTapGesture {
                            onSelect(.rest)
                        }
                }
                
                if slotType == .primaryFocus {
                    Section("Jobs") {
                        ForEach(Activity.allJobs, id: \.id) { job in
                            ActivityPickerRow(activity: job)
                                .onTapGesture {
                                    onSelect(job)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Choose Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ActivityPickerRow: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.icon)
                .foregroundStyle(.cadencePrimary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.cadenceBody)
                
                Text(activity.description)
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
            }
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
