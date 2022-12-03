import Foundation

public protocol LocalTimerCommands {
    func startTimer(completion: @escaping (ElapsedSeconds) -> Void)
    func pauseTimer(completion: @escaping (ElapsedSeconds) -> Void)
    func skipTimer(completion: @escaping (ElapsedSeconds) -> Void)
    func stopTimer(completion: @escaping (ElapsedSeconds) -> Void)
}

public class LocalTimer: LocalTimerCommands {
    private let timer: TimerCountdown
    
    public init(timer: TimerCountdown) {
        self.timer = timer
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
