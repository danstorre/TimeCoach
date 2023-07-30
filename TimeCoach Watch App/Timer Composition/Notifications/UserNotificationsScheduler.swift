import Foundation
import UserNotifications
import LifeCoach

public class UserNotificationsScheduler: Scheduler {
    private let currentDate: () -> Date
    private let notificationCenter: NotificationScheduler
    
    public init(currentDate: @escaping () -> Date = Date.init, with notificationCenter: NotificationScheduler) {
        self.notificationCenter = notificationCenter
        self.currentDate = currentDate
    }
    
    public func setSchedule(at date: Date) {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        
        let timeInterval = currentDate().distance(to: date)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "timer's up!"
        content.interruptionLevel = .critical
        
        let notification = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(notification)
    }
}
