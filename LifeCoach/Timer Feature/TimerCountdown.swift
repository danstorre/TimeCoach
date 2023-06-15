import Foundation

public protocol TimerCountdown {
    typealias TimerCompletion = (ElapsedSeconds) -> Void
    func startCountdown(completion: @escaping TimerCompletion)
    func pauseCountdown(completion: @escaping TimerCompletion)
    func skipCountdown(completion: @escaping TimerCompletion)
    func stopCountdown(completion: @escaping TimerCompletion)
}
