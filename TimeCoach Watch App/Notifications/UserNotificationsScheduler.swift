import Foundation
import UserNotifications
import LifeCoach

public class UserNotificationsScheduler: Scheduler {
    private let currentDate: () -> Date
    private let notificationCenter: NotificationScheduler
    
    public enum Error: Swift.Error {
        case invalidDate
    }
    
    public init(currentDate: @escaping () -> Date = Date.init, with notificationCenter: NotificationScheduler) {
        self.notificationCenter = notificationCenter
        self.currentDate = currentDate
    }
    
    public func setSchedule(at date: Date, isBreak: Bool) throws {
        guard currentDate().distance(to: date) >= 1 else {
            throw Error.invalidDate
        }
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        
        let timeInterval = currentDate().distance(to: date)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = isBreak ? "Break complete" : "Pomodoro complete"
        content.body = isBreak ? "Continue doing a great work." : "Nice work!"
        content.interruptionLevel = .critical
        
        let notification = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(notification, withCompletionHandler: {_ in })
    }
}
