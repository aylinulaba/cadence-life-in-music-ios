import SwiftUI

struct SocialView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
                Text("Social")
                    .font(.title)
                Text("Coming Soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Social")
        }
    }
}

#Preview {
    SocialView()
}
