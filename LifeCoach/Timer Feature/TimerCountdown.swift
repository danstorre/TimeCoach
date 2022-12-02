import Foundation

public protocol TimerCountdown {
    typealias TimerCompletion = (LocalElapsedSeconds) -> Void
    func startCountdown(completion: @escaping TimerCompletion)
    func pauseCountdown(completion: @escaping TimerCompletion)
    func skipCountdown(completion: @escaping TimerCompletion)
    func stopCountdown(completion: @escaping TimerCompletion)
}
