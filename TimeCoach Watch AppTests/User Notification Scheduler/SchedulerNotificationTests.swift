import LifeCoach
import XCTest
import UserNotifications

class UserNotificationsScheduler {
    private let currentDate: () -> Date
    private let notificationCenter: NotificationScheduler
    
    init(currentDate: @escaping () -> Date = Date.init, with notificationCenter: NotificationScheduler) {
        self.notificationCenter = notificationCenter
        self.currentDate = currentDate
    }
    
    func setSchedule(at date: Date) {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        
        let timeInterval = currentDate().distance(to: date)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let notification = UNNotificationRequest(identifier: "", content: .init(), trigger: trigger)
        
        notificationCenter.add(notification)
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
        
        sut.setSchedule(at: anyScheduledDate())
        
        XCTAssertEqual(fake.removeAllDeliveredNotificationsCallCount, 1)
    }
    
    func test_schedule_sendsMessageToRemoveAllPendingNotifications() {
        let fake = UNUserNotificationCenterSpy()
        let sut = UserNotificationsScheduler(with: fake)
        
        sut.setSchedule(at: anyScheduledDate())
        
        XCTAssertEqual(fake.removeAllPendingNotificationRequestsCallCount, 1)
    }
    
    func test_schedule_schedulesAtriggerOnRemainingTimeFromDateGiven() {
        let samplesAddingToCurrentDate: [TimeInterval] = [1, 2, 100]
        
        samplesAddingToCurrentDate.forEach { sample in
            let currentDate = Date()
            let fake = UNUserNotificationCenterSpy()
            let sut = UserNotificationsScheduler(currentDate: { currentDate }, with: fake)
            let timeScheduled = currentDate.adding(seconds: sample)
            sut.setSchedule(at: timeScheduled)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sample, repeats: false)
            
            XCTAssertEqual(fake.receivedNotifications.first?.trigger, trigger)
        }
    }
    
    // MARK: - Helpers
    class UNUserNotificationCenterSpy: NotificationScheduler {
        private(set) var removeAllDeliveredNotificationsCallCount = 0
        private(set) var removeAllPendingNotificationRequestsCallCount = 0
        private(set) var receivedNotifications = [UNNotificationRequest]()
        
        func removeAllDeliveredNotifications() {
            removeAllDeliveredNotificationsCallCount += 1
        }
        
        func removeAllPendingNotificationRequests() {
            removeAllPendingNotificationRequestsCallCount += 1
        }
        
        func add(_ notification: UNNotificationRequest) {
            receivedNotifications.append(notification)
        }
    }
    
    private func anyScheduledDate() -> Date {
        Date().adding(seconds: 1)
    }
}

protocol NotificationScheduler {
    func removeAllDeliveredNotifications()
    func removeAllPendingNotificationRequests()
    
    func add(_ notification: UNNotificationRequest)
}


extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
