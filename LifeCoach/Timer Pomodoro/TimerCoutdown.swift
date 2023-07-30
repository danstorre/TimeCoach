import Foundation

public enum TimerCoutdownState {
    case pause
    case running
    case stop
}

public protocol TimerCoutdown {
    
    var currentSetElapsedTime: TimeInterval { get }
    var state: TimerCoutdownState { get }
    
    typealias Result = Swift.Result<LocalTimerSet, Error>
    typealias StartCoundownCompletion = (Result) -> Void
    typealias SkipCountdownCompletion = (Result) -> Void
    func startCountdown(completion: @escaping StartCoundownCompletion)
    func stopCountdown()
    func pauseCountdown()
    func skipCountdown(completion: @escaping SkipCountdownCompletion)
}
