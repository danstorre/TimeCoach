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
        let currentDate = Date()
        let (sut, spy) = makeSUT(on: { currentDate })
        
        try? sut.setSchedule(at: currentDate.adding(seconds: 1), isBreak: false)
        
        XCTAssertEqual(spy.removeAllDeliveredNotificationsCallCount, 1)
    }
    
    func test_schedule_sendsMessageToRemoveAllPendingNotifications() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(on: { currentDate })
        
        try? sut.setSchedule(at: currentDate.adding(seconds: 1), isBreak: false)
        
        XCTAssertEqual(spy.removeAllPendingNotificationRequestsCallCount, 1)
    }
    
    func test_schedule_schedulesCorrectTrigger() {
        samplesAddingToCurrentDate().forEach { sample in
            let currentDate = Date()
            let (sut, mock) = makeSUT(on: { currentDate })
            let timeScheduled = currentDate.adding(seconds: sample.timeIntevalTrigger)
            try? sut.setSchedule(at: timeScheduled, isBreak: sample.isBreak)
            
            mock.assertCorrectTrigger(from: sample.timeIntevalTrigger)
        }
    }
    
    func test_schedule_schedulesCorrectContent() {
        samplesAddingToCurrentDate().forEach { sample in
            let currentDate = Date()
            let (sut, mock) = makeSUT(on: { currentDate })
            let timeScheduled = currentDate.adding(seconds: sample.timeIntevalTrigger)
            try? sut.setSchedule(at: timeScheduled, isBreak: sample.isBreak)
            
            mock.assertCorrectContent(isBreak: sample.isBreak)
        }
    }
    
    func test_schedule_schedulesCorrectNotificationRequest() {
        samplesAddingToCurrentDate().forEach { sample in
            let currentDate = Date()
            let (sut, mock) = makeSUT(on: { currentDate })
            let timeScheduled = currentDate.adding(seconds: sample.timeIntevalTrigger)
            try? sut.setSchedule(at: timeScheduled, isBreak: false)
            
            mock.assertCorrectNotificationRequest()
        }
    }
    
    func test_schedule_onInvalidDateDeliversError() {
        let expectedError = UserNotificationsScheduler.Error.invalidDate
        let currentDate = Date()
        let invalidDate = currentDate.addingTimeInterval(-1)
        let (sut, _) = makeSUT(on: { currentDate })
        
        do {
            try sut.setSchedule(at: invalidDate, isBreak: false)
            
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
        
        func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
            receivedNotifications.append(request)
        }
        
        func assertCorrectTrigger(from sample: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sample, repeats: false)
            
            XCTAssertEqual(receivedNotifications.first?.trigger, trigger, file: file, line: line)
        }
        
        func assertCorrectContent(isBreak: Bool, file: StaticString = #filePath, line: UInt = #line) {
            let content = UNMutableNotificationContent()
            content.title = isBreak ? "Break complete" : "Pomodoro complete"
            content.body = isBreak ? "Continue doing a great work." : "Nice work!"
            content.interruptionLevel = .critical
            
            XCTAssertEqual(receivedNotifications.first?.content, content, "on isBreak mode: \(isBreak)", file: file, line: line)
        }
        
        func assertCorrectNotificationRequest(file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertFalse(receivedNotifications.first!.identifier.isEmpty, "notification identifier should not be empty", file: file, line: line)
        }
    }
    
    private func samplesAddingToCurrentDate() -> [NotificationValue] {
        [
            NotificationValue(isBreak: false, timeIntevalTrigger: 1),
            NotificationValue(isBreak: false, timeIntevalTrigger: 2),
            NotificationValue(isBreak: false, timeIntevalTrigger: 100),
            NotificationValue(isBreak: true, timeIntevalTrigger: 1),
            NotificationValue(isBreak: true, timeIntevalTrigger: 2),
            NotificationValue(isBreak: true, timeIntevalTrigger: 100),
        ]
    }
    
    private func anyScheduledDate() -> Date {
        Date().adding(seconds: 1)
    }
    
    private struct NotificationValue {
        let isBreak: Bool
        let timeIntevalTrigger: TimeInterval
    }
}

extension UNTimeIntervalNotificationTrigger {
    open override var description: String {
        return "timeInterval \(timeInterval)"
    }
}
