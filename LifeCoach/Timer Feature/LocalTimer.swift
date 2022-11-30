import Foundation

public protocol StartTimer {
    func startCountdown(from date: Date, endDate: Date)
}

public class LocalTimer {
    private let timer: StartTimer
    private var mode: TimerMode = .pomodoroTime
    private var isPomodoro = true
    
    private enum TimerMode {
        case pomodoroTime
        case breakTime
    }
    
    public init(timer: StartTimer) {
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
}
