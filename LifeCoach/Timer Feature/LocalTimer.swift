import Foundation

public class LocalTimer {
    private let timer: TimerCountdown
    private let primaryTime: TimeInterval
    
    public init(timer: TimerCountdown, primaryTime: TimeInterval = .pomodoroInSeconds) {
        self.timer = timer
        self.primaryTime = primaryTime
    }
    
    public func startTimer(completion: @escaping (ElapsedSeconds) -> Void) {
        timer.startCountdown() {
            completion($0.timeElapsed)
        }
    }
    
    public func pauseTimer(completion: @escaping (ElapsedSeconds) -> Void) {
        timer.pauseCountdown() {
            completion($0.timeElapsed)
        }
    }
    
    public func skipTimer(completion: @escaping (ElapsedSeconds) -> Void) {
        timer.skipCountdown() {
            completion($0.timeElapsed)
        }
    }
    
    public func stopTimer(completion: @escaping (ElapsedSeconds) -> Void) {
        timer.stopCountdown() {
            completion($0.timeElapsed)
        }
    }
}
