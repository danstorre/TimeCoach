import Foundation

public enum TimerCountdownState {
    case pause
    case running
    case stop
}

public struct TimerCountDownState {
    public let state: TimerCountdownState
    public let currentTimerSet: LocalTimerSet
    
    public init(state: TimerCountdownState, currentTimerSet: LocalTimerSet) {
        self.state = state
        self.currentTimerSet = currentTimerSet
    }
}

public protocol TimerCountdown {
    
    var currentSetElapsedTime: TimeInterval { get }
    var currentState: TimerCountDownState { get }
    
    typealias Result = Swift.Result<(LocalTimerSet, TimerCountdownState), Error>
    typealias StartCoundownCompletion = (Result) -> Void
    typealias SkipCountdownCompletion = (Result) -> Void
    func startCountdown(completion: @escaping StartCoundownCompletion)
    func stopCountdown()
    func pauseCountdown()
    func skipCountdown(completion: @escaping SkipCountdownCompletion)
}
