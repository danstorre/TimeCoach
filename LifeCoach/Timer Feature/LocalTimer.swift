import Foundation

public protocol StartTimer {
    func startCountdown(from date: Date, endDate: Date)
}

public protocol PauseTimer {
    func pauseCountdown()
}

public class LocalTimer {
    public typealias TimerCountdown = StartTimer & PauseTimer
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
    
    public func pauseTimer() {
        timer.pauseCountdown()
    }
}
