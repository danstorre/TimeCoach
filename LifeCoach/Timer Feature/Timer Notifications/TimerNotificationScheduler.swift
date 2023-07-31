import Foundation

public protocol TimerNotificationScheduler {
    func scheduleNotification(from set: TimerSet) throws
}
