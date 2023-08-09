import Foundation
import UserNotifications

class UNUserNotificationCenterDelegateComposite: NSObject, UNUserNotificationCenterDelegate {
    private let delegates: [UNUserNotificationCenterDelegate]

    init(delegates: [UNUserNotificationCenterDelegate]) {
        self.delegates = delegates
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        delegates.forEach { delegate in
            delegate.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
        }
    }
}
