import Foundation

public protocol TimerStateValues {
    var currentState: TimerCountDownState { get }
    var currentSetElapsedTime: TimeInterval { get }
}

public protocol TimerCommands {
    typealias Result = Swift.Result<(TimerCountdownSet, TimerCountdownStateValues), Error>
    typealias StartCoundownCompletion = (Result) -> Void
    typealias SkipCountdownCompletion = (Result) -> Void
    func startCountdown(completion: @escaping StartCoundownCompletion)
    func stopCountdown()
    func pauseCountdown()
    func skipCountdown(completion: @escaping SkipCountdownCompletion)
}

public typealias TimerCountdown = TimerCommands & TimerStateValues
