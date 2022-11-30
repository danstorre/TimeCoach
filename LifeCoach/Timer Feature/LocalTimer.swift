import Foundation

public protocol StartTimer {
    func startCountdown(from date: Date, endDate: Date)
}

public protocol PauseTimer {
    typealias TimerCompletion = (LocalElapsedSeconds) -> Void
    func pauseCountdown(completion: @escaping TimerCompletion)
}

public protocol SkipTimer {
    typealias TimerCompletion = (LocalElapsedSeconds) -> Void
    func skipCountdown(completion: @escaping TimerCompletion)
}

public protocol StopTimer {
    typealias TimerCompletion = (LocalElapsedSeconds) -> Void
    func stopCountdown(completion: @escaping TimerCompletion)
}

public struct LocalElapsedSeconds {
    public let elapsedSeconds: TimeInterval
    public let startDate: Date
    public let endDate: Date

    public init(
        _ elapsedSeconds: TimeInterval,
        startDate: Date,
        endDate: Date
    ) {
        self.elapsedSeconds = elapsedSeconds
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var timeElapsed: ElapsedSeconds {
        ElapsedSeconds.init(elapsedSeconds,
                            startDate: startDate,
                            endDate: endDate)
    }
}

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
    
    public func startTimer(from startDate: Date = .now) {
        let endTime: Date
        if isPomodoro {
            endTime = startDate.adding(seconds: .pomodoroInSeconds)
        } else {
            endTime = startDate.adding(seconds: .breakInSeconds)
        }
        
        isPomodoro = !isPomodoro
        
        timer.startCountdown(from: startDate,
                             endDate: endTime)
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
