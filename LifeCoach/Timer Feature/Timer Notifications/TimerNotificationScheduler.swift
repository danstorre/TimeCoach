import Foundation

public protocol TimerNotificationScheduler {
    func scheduleNotification(from set: TimerSet, isBreak: Bool) throws
}
