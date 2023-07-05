import Foundation
import LifeCoach
import Combine

class TimerCoutdownToTimerStateAdapter: TimerCoutdown {
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
    var state: LifeCoach.TimerState {
        timer.state
    }
    
    @Published var isRunning = false
    
    init(timer: TimerCoutdown) {
        self.timer = timer
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
