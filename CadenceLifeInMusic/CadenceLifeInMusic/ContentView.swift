import SwiftUI
import CadenceCore

struct ContentView: View {
    @State private var testResult = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Database Test")
                .font(.title)
            
            Button("Test Database Connection") {
                testDatabase()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if !testResult.isEmpty {
                Text(testResult)
                    .padding()
                    .foregroundColor(testResult.contains("SUCCESS") ? .green : .red)
            }
            
            Spacer()
        }
        .padding()
        .alert("Test Result", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(testResult)
        }
    }
    
    private func testDatabase() {
        testResult = "Testing..."
        print("=== BUTTON PRESSED ===")
        print("Starting test...")
        
        Task {
            do {
                print("About to call DatabaseService...")
                try await DatabaseService.shared.testConnection()
                
                await MainActor.run {
                    testResult = "SUCCESS: Database connected!"
                    showAlert = true
                }
                print("=== TEST SUCCESS ===")
                
            } catch {
                await MainActor.run {
                    testResult = "FAILED: \(error.localizedDescription)"
                    showAlert = true
                }
                print("=== TEST FAILED ===")
                print("Error: \(error)")
            }
        }
    }
}
