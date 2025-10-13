import SwiftUI

struct MusicView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "music.note")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
                Text("Music")
                    .font(.title)
                Text("Coming Soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Music")
        }
    }
}

#Preview {
    MusicView()
}
