import Foundation

public class LocalTimer {
    public typealias TimerCountdown = StartTimer & PauseTimer & SkipTimer & StopTimer
    private let timer: TimerCountdown
    private var isPomodoro = true
    
    private enum TimerMode {
        case pomodoroTime
        case breakTime
    }
    
    public init(timer: TimerCountdown) {
        self.timer = timer
    }
    
    public func startTimer(from startDate: Date = .now, completion: @escaping (ElapsedSeconds) -> Void) {
        let endTime: Date
        if isPomodoro {
            endTime = startDate.adding(seconds: .pomodoroInSeconds)
        } else {
            endTime = startDate.adding(seconds: .breakInSeconds)
        }
        
        isPomodoro = !isPomodoro
        
        timer.startCountdown(from: startDate,
                             endDate: endTime) {
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
