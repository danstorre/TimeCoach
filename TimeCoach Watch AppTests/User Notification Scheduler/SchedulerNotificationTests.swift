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
        
        let content = UNMutableNotificationContent()
        content.title = "timer's up!"
        content.interruptionLevel = .critical
        
        let notification = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(notification)
    }
}

final class SchedulerNotificationTests: XCTestCase {
    func test_init_doesNotRemoveAllDeliveredNotifications() throws {
        let spy = UNUserNotificationCenterTestDouble()
        let _ = UserNotificationsScheduler(with: spy)
        
        XCTAssertEqual(spy.removeAllDeliveredNotificationsCallCount, 0)
    }
    
    func test_schedule_sendsMessageToRemoveAllDeliveredNotifications() {
        let spy = UNUserNotificationCenterTestDouble()
        let sut = UserNotificationsScheduler(with: spy)
        
        sut.setSchedule(at: anyScheduledDate())
        
        XCTAssertEqual(spy.removeAllDeliveredNotificationsCallCount, 1)
    }
    
    func test_schedule_sendsMessageToRemoveAllPendingNotifications() {
        let spy = UNUserNotificationCenterTestDouble()
        let sut = UserNotificationsScheduler(with: spy)
        
        sut.setSchedule(at: anyScheduledDate())
        
        XCTAssertEqual(spy.removeAllPendingNotificationRequestsCallCount, 1)
    }
    
    func test_schedule_schedulesAtriggerOnRemainingTimeFromDateGiven() {
        let samplesAddingToCurrentDate: [TimeInterval] = [1, 2, 100]
        
        samplesAddingToCurrentDate.forEach { sample in
            let currentDate = Date()
            let mock = UNUserNotificationCenterTestDouble()
            let sut = UserNotificationsScheduler(currentDate: { currentDate }, with: mock)
            let timeScheduled = currentDate.adding(seconds: sample)
            sut.setSchedule(at: timeScheduled)
            
            mock.assertCorrectTrigger(from: sample)
        }
    }
    
    func test_schedule_schedulesCorrectContent() {
        let samplesAddingToCurrentDate: [TimeInterval] = [1, 2, 100]
        
        samplesAddingToCurrentDate.forEach { sample in
            let currentDate = Date()
            let mock = UNUserNotificationCenterTestDouble()
            let sut = UserNotificationsScheduler(currentDate: { currentDate }, with: mock)
            let timeScheduled = currentDate.adding(seconds: sample)
            sut.setSchedule(at: timeScheduled)
            
            mock.assertCorrectContent(from: sample)
        }
    }
    
    func test_schedule_schedulesCorrectNotificationRequest() {
        let samplesAddingToCurrentDate: [TimeInterval] = [1, 2, 100]
        
        samplesAddingToCurrentDate.forEach { sample in
            let currentDate = Date()
            let mock = UNUserNotificationCenterTestDouble()
            let sut = UserNotificationsScheduler(currentDate: { currentDate }, with: mock)
            let timeScheduled = currentDate.adding(seconds: sample)
            sut.setSchedule(at: timeScheduled)
            
            mock.assertCorrectNotificationRequest()
        }
    }
    
    // MARK: - Helpers
    class UNUserNotificationCenterTestDouble: NotificationScheduler {
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
        
        func assertCorrectTrigger(from sample: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sample, repeats: false)
            
            XCTAssertEqual(receivedNotifications.first?.trigger, trigger, file: file, line: line)
        }
        
        func assertCorrectContent(from sample: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
            let content = UNMutableNotificationContent()
            content.title = "timer's up!"
            content.interruptionLevel = .critical
            
            XCTAssertEqual(receivedNotifications.first?.content, content, file: file, line: line)
        }
        
        func assertCorrectNotificationRequest(file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertFalse(receivedNotifications.first!.identifier.isEmpty, "notification identifier should not be empty", file: file, line: line)
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

extension UNTimeIntervalNotificationTrigger {
    open override var description: String {
        return "timeInterval \(timeInterval)"
    }
}
