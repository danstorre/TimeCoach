import Foundation

public protocol TimerNativeCommands {
    func startTimer(completion: @escaping (TimeInterval) -> Void)
    func invalidateTimer()
    func suspend()
    func resume()
}
