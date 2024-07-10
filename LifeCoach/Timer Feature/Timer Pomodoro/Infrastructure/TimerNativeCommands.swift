import Foundation

public protocol TimerNativeCommands {
    func startTimer(completion: @escaping () -> Void)
    func invalidateTimer()
    func suspend()
    func resume()
}
