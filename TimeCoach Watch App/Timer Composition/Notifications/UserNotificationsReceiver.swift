import Foundation
import UserNotifications
import LifeCoach

public class UserNotificationsReceiver: NSObject, UNUserNotificationCenterDelegate {
    private let receiver: TimerNotificationReceiver
    
    public init(receiver: TimerNotificationReceiver) {
        self.receiver = receiver
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        receiver.receiveNotification()
        
        completionHandler(.banner)
    }
}
