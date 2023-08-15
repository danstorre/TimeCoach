import Foundation
import UserNotifications

public protocol NotificationScheduler {
    func removeAllDeliveredNotifications()
    func removeAllPendingNotificationRequests()
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
}
