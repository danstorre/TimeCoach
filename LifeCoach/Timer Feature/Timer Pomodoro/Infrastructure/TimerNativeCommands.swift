import Foundation

public protocol TimerNativeCommands {
    typealias TimerPulse = (TimeInterval) -> Void
    func startTimer(completion: @escaping TimerPulse)
    func invalidateTimer()
    func suspend()
    func resume()
}
