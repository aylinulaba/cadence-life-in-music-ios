import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Global app background
            Color("BackgroundBase").ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Hello, Cadence!")
                    .font(.custom("Poppins-SemiBold", size: 24))
                    .foregroundStyle(Color("TextPrimary"))

                HStack(spacing: 28) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(Color("IconPrimary"))

                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            Color("AccentBlue600"),
                            Color("IconPrimary")
                        )

                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color("IconPrimary"))
                }
                .padding()
                .background(Color("SurfaceLight"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .tint(Color("AccentBlue600")) // default accent (buton/link)
        }
    }
}

#Preview { ContentView() }
