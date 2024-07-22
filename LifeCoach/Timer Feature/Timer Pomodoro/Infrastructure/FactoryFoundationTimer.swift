import Foundation

public enum FactoryFoundationTimer {
    public static func createTimer(startingSet: TimerCountdownSet,
                                   nextSet: TimerCountdownSet,
                                   timer: TimerNativeCommands,
                                   dispatchQueue: DispatchQueue = DispatchQueue.main)
    -> FoundationTimerCountdown {
        return FoundationTimerCountdown(
            startingSet: startingSet,
            nextSet: nextSet,
            timer: timer)
    }
}
