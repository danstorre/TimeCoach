import LifeCoach
import XCTest
import UserNotifications
import TimeCoach_Watch_App

final class SchedulerNotificationTests: XCTestCase {
    func test_init_doesNotRemoveAllDeliveredNotifications() throws {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.removeAllDeliveredNotificationsCallCount, 0)
    }
    
    func test_schedule_sendsMessageToRemoveAllDeliveredNotifications() {
        let (sut, spy) = makeSUT()
        
        try? sut.setSchedule(at: anyScheduledDate())
        
        XCTAssertEqual(spy.removeAllDeliveredNotificationsCallCount, 1)
    }
    
    func test_schedule_sendsMessageToRemoveAllPendingNotifications() {
        let (sut, spy) = makeSUT()
        
        try? sut.setSchedule(at: anyScheduledDate())
        
        XCTAssertEqual(spy.removeAllPendingNotificationRequestsCallCount, 1)
    }
    
    func test_schedule_schedulesCorrectTrigger() {
        let samplesAddingToCurrentDate: [TimeInterval] = [1, 2, 100]
        
        samplesAddingToCurrentDate.forEach { sample in
            let currentDate = Date()
            let (sut, mock) = makeSUT(on: { currentDate })
            let timeScheduled = currentDate.adding(seconds: sample)
            try? sut.setSchedule(at: timeScheduled)
            
            mock.assertCorrectTrigger(from: sample)
        }
    }
    
    func test_schedule_schedulesCorrectContent() {
        let samplesAddingToCurrentDate: [TimeInterval] = [1, 2, 100]
        
        samplesAddingToCurrentDate.forEach { sample in
            let currentDate = Date()
            let (sut, mock) = makeSUT(on: { currentDate })
            let timeScheduled = currentDate.adding(seconds: sample)
            try? sut.setSchedule(at: timeScheduled)
            
            mock.assertCorrectContent(from: sample)
        }
    }
    
    func test_schedule_schedulesCorrectNotificationRequest() {
        let samplesAddingToCurrentDate: [TimeInterval] = [1, 2, 100]
        
        samplesAddingToCurrentDate.forEach { sample in
            let currentDate = Date()
            let (sut, mock) = makeSUT(on: { currentDate })
            let timeScheduled = currentDate.adding(seconds: sample)
            try? sut.setSchedule(at: timeScheduled)
            
            mock.assertCorrectNotificationRequest()
        }
    }
    
    func test_schedule_onInvalidDateDeliversError() {
        let expectedError = UserNotificationsScheduler.Error.invalidDate
        let currentDate = Date()
        let invalidDate = currentDate.addingTimeInterval(-1)
        let (sut, _) = makeSUT(on: { currentDate })
        
        do {
            try sut.setSchedule(at: invalidDate)
            
            XCTFail("setSchedule should have failed on invalid date.")
        } catch {
            XCTAssertEqual(error as? UserNotificationsScheduler.Error, expectedError)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(on currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (Scheduler, UNUserNotificationCenterTestDouble) {
        let mock = UNUserNotificationCenterTestDouble()
        let sut = UserNotificationsScheduler(currentDate: currentDate, with: mock)
        
        trackForMemoryLeak(instance: mock, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, mock)
    }
    
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
