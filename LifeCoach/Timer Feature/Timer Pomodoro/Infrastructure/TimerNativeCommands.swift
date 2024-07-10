import Foundation

public protocol TimerNativeCommands {
    func startTimer(completion: @escaping () -> Void)
    func invalidatesTimer()
    func suspendCurrentTimer()
    func resumeCurrentTimer()
}
