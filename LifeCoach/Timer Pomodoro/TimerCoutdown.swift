import Foundation

public protocol TimerCoutdown {
    typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    func startCountdown(completion: @escaping StartCoundownCompletion)
    func stopCountdown()
    func pauseCountdown()
    func skipCountdown()
}