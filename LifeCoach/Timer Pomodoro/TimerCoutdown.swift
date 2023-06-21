import Foundation

public protocol TimerCoutdown {
    typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    typealias SkipCountdownCompletion = (Error) -> Void
    func startCountdown(completion: @escaping StartCoundownCompletion)
    func stopCountdown()
    func pauseCountdown()
    func skipCountdown(completion: @escaping SkipCountdownCompletion)
}
