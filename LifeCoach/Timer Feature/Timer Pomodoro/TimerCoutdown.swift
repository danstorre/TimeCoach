import Foundation

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

public protocol TimerNativeCommands {
    func startTimer(completion: @escaping () -> Void)
    func invalidatesTimer()
    func suspedCurrentTimer()
    func resumeCurrentTimer()
}
