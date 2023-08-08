import Foundation
import LifeCoach
import Combine

class TimerCoutdownToTimerStateAdapter: TimerCoutdown {
    var currentTimerSet: LifeCoach.LocalTimerSet
    
    var isPlaying: Bool {
        switch timer.state {
        case .running: return true
        case .pause, .stop: return false
        }
    }
    
    private let timer: TimerCoutdown
    var currentSetElapsedTime: TimeInterval {
        timer.currentSetElapsedTime
    }
    var state: LifeCoach.TimerCoutdownState {
        timer.state
    }
    
    @Published var isRunning = false
    
    private let currentDate: () -> Date
    
    init(timer: TimerCoutdown, currentDate: @escaping () -> Date) {
        self.timer = timer
        self.currentDate = currentDate
        self.currentTimerSet = .pomodoroSet(date: currentDate())
    }
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        timer.startCountdown { [unowned self] result in
            self.isRunning = self.isPlaying
            completion(result)
        }
        isRunning = isPlaying
    }
    
    func stopCountdown() {
        timer.stopCountdown()
        isRunning = isPlaying
    }
    
    func pauseCountdown() {
        timer.pauseCountdown()
        isRunning = isPlaying
    }
    
    func skipCountdown(completion: @escaping SkipCountdownCompletion) {
        timer.skipCountdown{ [unowned self] result in
            self.isRunning = self.isPlaying
            completion(result)
        }
        isRunning = isPlaying
    }
}
