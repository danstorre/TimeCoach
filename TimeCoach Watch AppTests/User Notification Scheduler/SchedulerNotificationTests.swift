import LifeCoach
import XCTest
import UserNotifications

class UserNotificationsScheduler {
    private let notificationCenter: NotificationScheduler
    
    init(with notificationCenter: NotificationScheduler) {
        self.notificationCenter = notificationCenter
    }
    
    func setSchedule() {
        notificationCenter.removeAllDeliveredNotifications()
    }
}

final class SchedulerNotificationTests: XCTestCase {
    func test_init_doesNotRemoveAllDeliveredNotifications() throws {
        let fake = UNUserNotificationCenterSpy()
        let _ = UserNotificationsScheduler(with: fake)
        
        XCTAssertEqual(fake.removeAllDeliveredNotificationsCallCount, 0)
    }
    
    func test_schedule_sendsMessageToRemoveAllDeliveredNotifications() {
        let fake = UNUserNotificationCenterSpy()
        let sut = UserNotificationsScheduler(with: fake)
        
        sut.setSchedule()
        
        XCTAssertEqual(fake.removeAllDeliveredNotificationsCallCount, 1)
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
