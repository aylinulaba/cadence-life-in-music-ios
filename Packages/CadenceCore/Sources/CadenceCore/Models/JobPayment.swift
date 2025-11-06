import Foundation

/// Tracks scheduled and completed job payments
public struct JobPayment: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let playerID: UUID
    public let jobType: Activity.JobType
    public let amount: Decimal
    public let scheduledDate: Date
    public var paidDate: Date?
    public var status: PaymentStatus
    
    public enum PaymentStatus: String, Codable, Sendable {
        case pending
        case paid
        case cancelled
    }
    
    public init(
        id: UUID = UUID(),
        playerID: UUID,
        jobType: Activity.JobType,
        amount: Decimal,
        scheduledDate: Date,
        paidDate: Date? = nil,
        status: PaymentStatus = .pending
    ) {
        self.id = id
        self.playerID = playerID
        self.jobType = jobType
        self.amount = amount
        self.scheduledDate = scheduledDate
        self.paidDate = paidDate
        self.status = status
    }
    
    public var isPending: Bool {
        status == .pending
    }
    
    public var isPaid: Bool {
        status == .paid
    }
    
    public var isDue: Bool {
        isPending && scheduledDate <= Date()
    }
}

// MARK: - Job Payment Extensions

extension JobPayment {
    /// Creates the next weekly payment for a job
    public static func nextWeeklyPayment(
        for playerID: UUID,
        jobType: Activity.JobType,
        from lastPaymentDate: Date
    ) -> JobPayment {
        let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: lastPaymentDate) ?? lastPaymentDate
        
        return JobPayment(
            playerID: playerID,
            jobType: jobType,
            amount: jobType.weeklySalary,
            scheduledDate: nextDate
        )
    }
    
    /// Creates the first payment for a new job (immediate payment for first week)
    public static func firstPayment(
        for playerID: UUID,
        jobType: Activity.JobType,
        startDate: Date
    ) -> JobPayment {
        // First payment scheduled 7 days from start
        let firstPaymentDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        
        return JobPayment(
            playerID: playerID,
            jobType: jobType,
            amount: jobType.weeklySalary,
            scheduledDate: firstPaymentDate
        )
    }
}
