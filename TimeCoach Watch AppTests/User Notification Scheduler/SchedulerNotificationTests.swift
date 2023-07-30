import LifeCoach
import XCTest
import UserNotifications

class UserNotificationsScheduler {
    init(with: NotificationScheduler) {
        
    }
    
}

final class SchedulerNotificationTests: XCTestCase {
    func test_init_doesNotRemoveAllPendingNotifications() throws {
        let fake = UNUserNotificationCenterSpy()
        let _ = UserNotificationsScheduler(with: fake)
        
        XCTAssertEqual(fake.removeAllDeliveredNotificationsCallCount, 0)
    }
    
    // MARK: - Helpers
    class UNUserNotificationCenterSpy: NotificationScheduler {
        private(set) var removeAllDeliveredNotificationsCallCount = 0
        func removeAllDeliveredNotifications() {
            removeAllDeliveredNotificationsCallCount += 1
        }
    }
}

protocol NotificationScheduler {
    func removeAllDeliveredNotifications()
}
