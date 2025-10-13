import SwiftUI

public struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    let height: CGFloat
    
    public init(progress: Double, color: Color = .cadencePrimary, height: CGFloat = 8) {
        self.progress = min(max(progress, 0.0), 1.0)
        self.color = color
        self.height = height
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.cardBackground)
                
                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressBar(progress: 0.3, color: .cadencePrimary)
        ProgressBar(progress: 0.7, color: .healthGood)
        ProgressBar(progress: 1.0, color: .cadenceAccent)
    }
    .padding()
}
