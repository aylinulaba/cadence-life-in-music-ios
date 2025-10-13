import SwiftUI

struct EconomyView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
                Text("Economy")
                    .font(.title)
                Text("Coming Soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Economy")
        }
    }
}

#Preview {
    EconomyView()
}
