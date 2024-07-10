import Foundation

public protocol TimerNativeCommands {
    func startTimer(completion: @escaping () -> Void)
    func invalidatesTimer()
    func suspend()
    func resumeCurrentTimer()
}
