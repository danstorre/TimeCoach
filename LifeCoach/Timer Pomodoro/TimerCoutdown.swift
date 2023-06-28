import Foundation

public enum TimerState {
    case pause
    case running
    case stop
}

public protocol TimerCoutdown {
    
    var elapsedTime: TimeInterval { get }
    var state: TimerState { get }
    
    typealias Result = Swift.Result<LocalElapsedSeconds, Error>
    typealias StartCoundownCompletion = (Result) -> Void
    typealias SkipCountdownCompletion = (Result) -> Void
    func startCountdown(completion: @escaping StartCoundownCompletion)
    func stopCountdown()
    func pauseCountdown()
    func skipCountdown(completion: @escaping SkipCountdownCompletion)
}
