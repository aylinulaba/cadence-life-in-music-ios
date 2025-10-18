import SwiftUI
import CadenceCore
import CadenceUI

struct ActivityPickerView: View {
    let slotType: TimeSlot.SlotType
    let onSelect: (Activity) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Music Practice") {
                    ActivityRow(
                        icon: "🎸",
                        title: "Practice Guitar",
                        description: "Improve your Guitar skills. +10 XP/hour.",
                        activity: .practice(instrument: .guitar),
                        onSelect: onSelect
                    )
                    
                    ActivityRow(
                        icon: "🎹",
                        title: "Practice Piano",
                        description: "Improve your Piano skills. +10 XP/hour.",
                        activity: .practice(instrument: .piano),
                        onSelect: onSelect
                    )
                    
                    ActivityRow(
                        icon: "🥁",
                        title: "Practice Drums",
                        description: "Improve your Drums skills. +10 XP/hour.",
                        activity: .practice(instrument: .drums),
                        onSelect: onSelect
                    )
                    
                    ActivityRow(
                        icon: "🎸",
                        title: "Practice Bass",
                        description: "Improve your Bass skills. +10 XP/hour.",
                        activity: .practice(instrument: .bass),
                        onSelect: onSelect
                    )
                    
                    ActivityRow(
                        icon: "✍️",
                        title: "Practice Songwriting",
                        description: "Improve your Songwriting skills. +10 XP/hour.",
                        activity: .practice(instrument: .songwriting),
                        onSelect: onSelect
                    )
                    
                    ActivityRow(
                        icon: "🎤",
                        title: "Practice Performance",
                        description: "Improve your Performance skills. +10 XP/hour.",
                        activity: .practice(instrument: .performance),
                        onSelect: onSelect
                    )
                    
                    ActivityRow(
                        icon: "🎛️",
                        title: "Practice Production",
                        description: "Improve your Production skills. +10 XP/hour.",
                        activity: .practice(instrument: .production),
                        onSelect: onSelect
                    )
                }
                
                Section("Rest & Recovery") {
                    ActivityRow(
                        icon: "💤",
                        title: "Rest",
                        description: "Recover health and mood. +10 Health, +5 Mood per hour.",
                        activity: .rest,
                        onSelect: onSelect
                    )
                }
                
                if slotType == .primaryFocus {
                    Section("Jobs") {
                        ActivityRow(
                            icon: "🏪",
                            title: "Work as Cashier",
                            description: "Earn $150/week. Blocks primary focus slot.",
                            activity: .job(type: .cashier),
                            onSelect: onSelect
                        )
                        
                        ActivityRow(
                            icon: "👕",
                            title: "Work as Sales Clerk",
                            description: "Earn $150/week. Blocks primary focus slot.",
                            activity: .job(type: .salesClerk),
                            onSelect: onSelect
                        )
                        
                        ActivityRow(
                            icon: "☕",
                            title: "Work as Barista",
                            description: "Earn $175/week. Blocks primary focus slot.",
                            activity: .job(type: .barista),
                            onSelect: onSelect
                        )
                        
                        ActivityRow(
                            icon: "🍽️",
                            title: "Work as Waiter/Waitress",
                            description: "Earn $200/week. Blocks primary focus slot.",
                            activity: .job(type: .waiter),
                            onSelect: onSelect
                        )
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

struct ActivityRow: View {
    let icon: String
    let title: String
    let description: String
    let activity: Activity
    let onSelect: (Activity) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            onSelect(activity)
            dismiss()
        }) {
            HStack(spacing: Spacing.md) {
                Text(icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.cadenceBodyBold)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.cadenceCaption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, Spacing.xs)
        }
    }
}

#Preview {
    ActivityPickerView(
        slotType: .primaryFocus,
        onSelect: { _ in }
    )
}
