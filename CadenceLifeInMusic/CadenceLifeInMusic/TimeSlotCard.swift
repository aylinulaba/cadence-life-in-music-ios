import SwiftUI
import CadenceCore
import CadenceUI

struct TimeSlotCard: View {
    let slot: TimeSlot
    let onSetActivity: () -> Void
    let onClearActivity: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Image(systemName: slot.slotType == .primaryFocus ? "star.fill" : "clock.fill")
                    .foregroundStyle(.cadencePrimary)
                
                Text(slot.slotType == .primaryFocus ? "Primary Focus" : "Free Time")
                    .font(.cadenceHeadline)
                
                Spacer()
                
                if slot.currentActivity != nil {
                    Text(timeElapsed)
                        .font(.cadenceBody)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Activity Content
            if let activity = slot.currentActivity {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text(activityIcon(for: activity))
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activityName(for: activity))
                                .font(.cadenceBodyBold)
                            
                            Text(activityDescription(for: activity))
                                .font(.cadenceCaption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Button(action: onClearActivity) {
                        Text("Stop Activity")
                            .font(.cadenceBody)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            } else {
                Button(action: onSetActivity) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Set Activity")
                    }
                    .font(.cadenceBodyBold)
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
    
    private var timeElapsed: String {
        guard let startedAt = slot.startedAt else { return "0m" }
        let elapsed = Date().timeIntervalSince(startedAt)
        let minutes = Int(elapsed / 60)
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    private func activityIcon(for activity: Activity) -> String {
        switch activity {
        case .practice:
            return "🎵"
        case .rest:
            return "💤"
        case .job:
            return "💼"
        case .rehearsal:
            return "🎤"
        case .gig:
            return "🎸"
        }
    }
    
    private func activityName(for activity: Activity) -> String {
        activity.name
    }
    
    private func activityDescription(for activity: Activity) -> String {
        activity.description
    }
}

#Preview {
    let slot = TimeSlot(
        playerID: UUID(),
        slotType: .primaryFocus,
        currentActivity: .practice(instrument: .guitar),
        startedAt: Date().addingTimeInterval(-3600)
    )
    
    return TimeSlotCard(
        slot: slot,
        onSetActivity: {},
        onClearActivity: {}
    )
    .padding()
}
