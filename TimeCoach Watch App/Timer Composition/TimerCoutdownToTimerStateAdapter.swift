import Foundation
import LifeCoach
import Combine

class TimerCountdownToTimerStateAdapter: TimerCountdown {
    var currentState: LifeCoach.TimerCountDownState
    var currentSetElapsedTime: TimeInterval {
        timer.currentSetElapsedTime
    }
    
    private let currentDate: () -> Date
    @Published var isRunning = false
    private let timer: TimerCountdown
    var isPlaying: Bool {
        switch timer.currentState.state {
        case .running: return true
        case .pause, .stop: return false
        }
    }
    
    init(timer: TimerCountdown, currentDate: @escaping () -> Date) {
        self.timer = timer
        self.currentDate = currentDate
        self.currentState = .init(state: timer.currentState.state, currentTimerSet: .pomodoroSet(date: currentDate()))
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
