import SwiftUI
import CadenceCore

public struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    public init(title: String, value: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.cadenceCaption)
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.cadenceHeadline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    StatCard(
        title: "Health",
        value: "80",
        icon: "heart.fill",
        color: .healthGood
    )
    .padding()
}
