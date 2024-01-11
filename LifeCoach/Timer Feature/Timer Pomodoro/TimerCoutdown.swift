import Foundation

public enum TimerCountdownStateValues {
    case pause
    case running
    case stop
}

public protocol TimerCountdown {
    
    var currentSetElapsedTime: TimeInterval { get }
    var currentState: TimerCountDownState { get }
    
    typealias Result = Swift.Result<(LocalTimerSet, TimerCountdownStateValues), Error>
    typealias StartCoundownCompletion = (Result) -> Void
    typealias SkipCountdownCompletion = (Result) -> Void
    func startCountdown(completion: @escaping StartCoundownCompletion)
    func stopCountdown()
    func pauseCountdown()
    func skipCountdown(completion: @escaping SkipCountdownCompletion)
}
