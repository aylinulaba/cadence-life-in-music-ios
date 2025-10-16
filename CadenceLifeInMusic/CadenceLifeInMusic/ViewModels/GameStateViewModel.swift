import Foundation
import SwiftUI
import CadenceCore

@Observable
final class GameStateViewModel {
    var gameState: GameState
    var refreshTrigger: Int = 0
    
    private let progressionManager = IdleProgressionManager()
    private var updateTimer: Timer?
    
    init(gameState: GameState) {
        self.gameState = gameState
        startProgressionTimer()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // MARK: - Idle Progression
    
    private func startProgressionTimer() {
        // Schedule timer on main thread
        DispatchQueue.main.async { [weak self] in
            self?.updateTimer = Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { timer in
                self?.updateProgress()
            }
            
            // Ensure timer works during UI interactions
            if let timer = self?.updateTimer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    func updateProgress() {
        progressionManager.processIdleProgress(gameState: &gameState)
        refreshTrigger += 1
    }
    
    // MARK: - Activity Management
    
    func setActivity(_ activity: Activity, in slotType: TimeSlot.SlotType) {
        switch slotType {
        case .primaryFocus:
            gameState.primaryFocus.currentActivity = activity
            gameState.primaryFocus.startedAt = Date()
        case .freeTime:
            gameState.freeTime.currentActivity = activity
            gameState.freeTime.startedAt = Date()
        }
        refreshTrigger += 1
    }
    
    func clearActivity(in slotType: TimeSlot.SlotType) {
        switch slotType {
        case .primaryFocus:
            gameState.primaryFocus.currentActivity = nil
            gameState.primaryFocus.startedAt = nil
        case .freeTime:
            gameState.freeTime.currentActivity = nil
            gameState.freeTime.startedAt = nil
        }
        refreshTrigger += 1
    }
    
    // MARK: - Skill Access
    
    func skill(for type: Skill.SkillType) -> Skill? {
        gameState.skill(for: type)
    }
    
    // MARK: - Economy
    
    func addIncome(_ amount: Decimal, description: String) {
        gameState.wallet.addIncome(amount)
        refreshTrigger += 1
    }
    
    func deductExpense(_ amount: Decimal, description: String) throws {
        try gameState.wallet.deductExpense(amount)
        refreshTrigger += 1
    }
}
