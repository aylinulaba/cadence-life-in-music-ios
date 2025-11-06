import Foundation
import CadenceCore

/// Manages job payment scheduling and processing
public final class JobPaymentManager {
    
    public init() {}
    
    // MARK: - Job Start/Stop
    
    /// Called when a player starts a new job
    public func startJob(
        gameState: inout CadenceCore.GameState,
        jobType: CadenceCore.Activity.JobType,
        startDate: Date = Date()
    ) {
        // Cancel any pending payments from previous jobs
        cancelPendingPayments(gameState: &gameState)
        
        // Record job start date
        gameState.lastJobStartDate = startDate
        
        // Schedule first payment (7 days from start)
        let firstPayment = CadenceCore.JobPayment.firstPayment(
            for: gameState.player.id,
            jobType: jobType,
            startDate: startDate
        )
        
        gameState.addJobPayment(firstPayment)
    }
    
    /// Called when a player quits their job
    public func quitJob(gameState: inout CadenceCore.GameState) {
        // Cancel pending payments
        cancelPendingPayments(gameState: &gameState)
        
        // Clear job start date
        gameState.lastJobStartDate = nil
    }
    
    // MARK: - Payment Processing
    
    /// Process all due payments
    public func processDuePayments(gameState: inout CadenceCore.GameState) {
        let duePayments = gameState.duePayments
        
        for payment in duePayments {
            processPayment(gameState: &gameState, payment: payment)
        }
    }
    
    /// Process a single payment
    private func processPayment(gameState: inout CadenceCore.GameState, payment: CadenceCore.JobPayment) {
        guard payment.isDue else { return }
        
        // Add income to wallet
        gameState.wallet.addIncome(payment.amount)
        
        // Mark payment as paid
        gameState.markPaymentAsPaid(payment.id)
        
        // Schedule next payment if still employed
        if let currentJob = gameState.currentJob,
           currentJob == payment.jobType {
            scheduleNextPayment(gameState: &gameState, jobType: currentJob)
        }
    }
    
    // MARK: - Payment Scheduling
    
    /// Schedule the next weekly payment
    private func scheduleNextPayment(gameState: inout CadenceCore.GameState, jobType: CadenceCore.Activity.JobType) {
        // Find the last payment for this job type
        let lastPayment = gameState.jobPayments
            .filter { $0.jobType == jobType }
            .max { $0.scheduledDate < $1.scheduledDate }
        
        guard let lastPayment = lastPayment else { return }
        
        // Create next payment
        let nextPayment = CadenceCore.JobPayment.nextWeeklyPayment(
            for: gameState.player.id,
            jobType: jobType,
            from: lastPayment.scheduledDate
        )
        
        gameState.addJobPayment(nextPayment)
    }
    
    /// Cancel all pending payments
    private func cancelPendingPayments(gameState: inout CadenceCore.GameState) {
        for (index, payment) in gameState.jobPayments.enumerated() {
            if payment.isPending {
                gameState.jobPayments[index].status = .cancelled
            }
        }
    }
    
    // MARK: - Payment Info
    
    /// Calculate days until next payment
    public func daysUntilNextPayment(gameState: CadenceCore.GameState) -> Int? {
        guard let nextPaymentDate = gameState.nextPaymentDate else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let paymentDay = calendar.startOfDay(for: nextPaymentDate)
        
        let components = calendar.dateComponents([.day], from: today, to: paymentDay)
        return components.day
    }
    
    /// Calculate hours worked this week
    public func hoursWorkedThisWeek(gameState: CadenceCore.GameState) -> Double {
        guard let startDate = gameState.lastJobStartDate else { return 0 }
        
        let elapsed = Date().timeIntervalSince(startDate)
        let hours = elapsed / 3600
        
        // Cap at 168 hours (7 days * 24 hours)
        return min(hours, 168)
    }
    
    /// Get total earnings from current job
    public func totalEarningsFromCurrentJob(gameState: CadenceCore.GameState) -> Decimal {
        guard let currentJob = gameState.currentJob else { return 0 }
        
        return gameState.paidPayments
            .filter { $0.jobType == currentJob }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }
}
