import Foundation
import LifeCoach
import Combine

class TimerCountdownToTimerStateAdapter: TimerCountdown {
    var currentTimerSet: LifeCoach.LocalTimerSet
    
    var isPlaying: Bool {
        switch timer.state {
        case .running: return true
        case .pause, .stop: return false
        }
    }
    
    private let timer: TimerCountdown
    var currentSetElapsedTime: TimeInterval {
        timer.currentSetElapsedTime
    }
    var state: LifeCoach.TimerCountdownState {
        timer.state
    }
    
    @Published var isRunning = false
    
    private let currentDate: () -> Date
    
    init(timer: TimerCountdown, currentDate: @escaping () -> Date) {
        self.timer = timer
        self.currentDate = currentDate
        self.currentTimerSet = .pomodoroSet(date: currentDate())
    }
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        timer.startCountdown { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [unowned self] in
                self.isRunning = self.isPlaying
                completion(result)
            }
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
        timer.skipCountdown { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [unowned self] in
                self.isRunning = self.isPlaying
                completion(result)
            }
        }
        isRunning = isPlaying
    }
}
