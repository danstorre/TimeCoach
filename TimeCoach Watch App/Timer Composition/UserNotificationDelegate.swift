import LifeCoachWatchOS
import WatchKit
import UserNotifications

class UserNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.banner)
        WKInterfaceDevice.current().play(.notification)
    }
}

extension UserNotificationDelegate {
    static func registerNotificationOn(remainingTime: TimeInterval){
        guard remainingTime > 0 else { return }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remainingTime, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "timer's up!"
        content.interruptionLevel = .critical
        
        let notification = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(notification)
    }
}
