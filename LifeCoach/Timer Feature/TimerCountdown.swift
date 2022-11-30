import Foundation

public typealias TimerCountdown = StartTimer & PauseTimer & SkipTimer & StopTimer

public protocol StartTimer {
    typealias TimerCompletion = (LocalElapsedSeconds) -> Void
    func startCountdown(from date: Date, endDate: Date, completion: @escaping TimerCompletion)
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
