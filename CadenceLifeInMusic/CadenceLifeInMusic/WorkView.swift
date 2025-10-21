import SwiftUI
import CadenceCore

struct WorkView: View {
    let viewModel: GameStateViewModel
    @State private var selectedJobType: Activity.JobType?
    @State private var showJobDetails = false
    
    var currentJob: Activity.JobType? {
        if case .job(let jobType) = viewModel.gameState.primaryFocus.currentActivity {
            return jobType
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Job Status
                    if let job = currentJob {
                        CurrentJobView(jobType: job)
                    } else {
                        NoJobView()
                    }
                    
                    // Available Jobs
                    AvailableJobsView(
                        currentJob: currentJob,
                        onJobTap: { jobType in
                            selectedJobType = jobType
                            showJobDetails = true
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("Work")
            .background(Color(uiColor: .systemGroupedBackground))
            .sheet(isPresented: $showJobDetails) {
                if let jobType = selectedJobType {
                    JobDetailsSheet(
                        jobType: jobType,
                        viewModel: viewModel,
                        isPresented: $showJobDetails
                    )
                }
            }
        }
    }
}

// MARK: - Current Job View

struct CurrentJobView: View {
    let jobType: Activity.JobType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "briefcase.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Job")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(jobType.rawValue)
                        .font(.title3.bold())
                }
                
                Spacer()
            }
            
            Divider()
            
            // Job Details
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    Text("Weekly Salary")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(formatDecimal(jobType.weeklySalary))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    Text("Next Payday")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(nextPayday())
                        .font(.headline)
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.purple)
                    Text("Time Commitment")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Primary Focus")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
    
    private func nextPayday() -> String {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysUntilMonday = (9 - weekday) % 7
        let nextMonday = calendar.date(byAdding: .day, value: daysUntilMonday == 0 ? 7 : daysUntilMonday, to: today)!
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: nextMonday)
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

// MARK: - No Job View

struct NoJobView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "briefcase.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Current Job")
                .font(.title3.bold())
            
            Text("Browse available jobs below to start earning money")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Available Jobs

struct AvailableJobsView: View {
    let currentJob: Activity.JobType?
    let onJobTap: (Activity.JobType) -> Void
    
    let availableJobs: [Activity.JobType] = [.cashier, .salesClerk, .barista, .waiter]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Jobs")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(availableJobs, id: \.self) { jobType in
                    JobRowView(
                        jobType: jobType,
                        isCurrentJob: currentJob == jobType,
                        onTap: { onJobTap(jobType) }
                    )
                }
            }
        }
    }
}

// MARK: - Job Row

struct JobRowView: View {
    let jobType: Activity.JobType
    let isCurrentJob: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isCurrentJob ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: jobType.icon)
                        .font(.title3)
                        .foregroundColor(isCurrentJob ? .blue : .gray)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(jobType.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(jobType.workplace)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Salary
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(formatDecimal(jobType.weeklySalary))")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("per week")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if isCurrentJob {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCurrentJob ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

// MARK: - Job Details Sheet

struct JobDetailsSheet: View {
    let jobType: Activity.JobType
    let viewModel: GameStateViewModel
    @Binding var isPresented: Bool
    
    var isCurrentJob: Bool {
        if case .job(let currentJobType) = viewModel.gameState.primaryFocus.currentActivity {
            return currentJobType == jobType
        }
        return false
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: jobType.icon)
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        Text(jobType.rawValue)
                            .font(.title2.bold())
                        
                        Text(jobType.workplace)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About This Job")
                            .font(.headline)
                        
                        Text(jobType.description)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    
                    // Details
                    VStack(spacing: 16) {
                        DetailRow(
                            icon: "dollarsign.circle.fill",
                            title: "Weekly Salary",
                            value: "$\(formatDecimal(jobType.weeklySalary))",
                            color: .green
                        )
                        
                        DetailRow(
                            icon: "clock.fill",
                            title: "Time Commitment",
                            value: "Primary Focus",
                            color: .orange
                        )
                        
                        DetailRow(
                            icon: "arrow.up.right",
                            title: "Career Growth",
                            value: "None",
                            color: .purple
                        )
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    
                    // Action Button
                    if isCurrentJob {
                        Button(action: quitJob) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Quit Job")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    } else {
                        Button(action: takeJob) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Take This Job")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Job Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func takeJob() {
        var newSlot = viewModel.gameState.primaryFocus
        newSlot.currentActivity = .job(type: jobType)
        newSlot.startedAt = Date()
        
        viewModel.gameState.primaryFocus = newSlot
        isPresented = false
    }
    
    private func quitJob() {
        var newSlot = viewModel.gameState.primaryFocus
        newSlot.currentActivity = nil
        newSlot.startedAt = nil
        
        viewModel.gameState.primaryFocus = newSlot
        isPresented = false
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let nsDecimal = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
        }
    }
}

// MARK: - JobType Extensions

extension Activity.JobType {
    var icon: String {
        switch self {
        case .cashier: return "cart.fill"
        case .salesClerk: return "tag.fill"
        case .barista: return "cup.and.saucer.fill"
        case .waiter: return "fork.knife"
        }
    }
    
    var workplace: String {
        switch self {
        case .cashier: return "Supermarket"
        case .salesClerk: return "Retail Shop"
        case .barista: return "Coffee Shop"
        case .waiter: return "Restaurant"
        }
    }
    
    var description: String {
        switch self {
        case .cashier:
            return "Handle customer transactions and provide friendly service at the checkout counter."
        case .salesClerk:
            return "Assist customers, organize merchandise, and maintain store appearance."
        case .barista:
            return "Prepare coffee and beverages while creating a welcoming atmosphere for customers."
        case .waiter:
            return "Serve food and drinks to restaurant guests with excellent customer service."
        }
    }
}

// MARK: - Preview

#Preview {
    let player = Player(
        name: "Test Player",
        gender: .nonBinary,
        avatarID: "default",
        currentCityID: City.losAngeles.id
    )
    let gameState = GameState.new(player: player)
    
    return WorkView(viewModel: GameStateViewModel(gameState: gameState))
}
