import XCTest
import LifeCoach
import UserNotifications
import TimeCoach_Watch_App

final class ReceiverNotificationTests: XCTestCase {
    func test_init_shouldNotSendMessageToReceiver() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.receiveCallCount, 0)
    }
    
    func test_receive_sendsMessageToReceiver() {
        let (sut, spy) = makeSUT()
        
        sut.receiveNotification()
        
        XCTAssertEqual(spy.receiveCallCount, 1)
    }
    
    func test_receive_receivesCorrectNotificationType() {
        let (sut, _) = makeSUT()
        
        let receivedNoticicationType = sut.receiveNotification()
        
        assertNotificationType(with: receivedNoticicationType)
    }
    
    private class SpyReceiver: TimerNotificationReceiver {
        private(set) var receiveCallCount = 0
        
        func receiveNotification() {
            receiveCallCount += 1
        }
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: UserNotificationsReceiver, spy: SpyReceiver) {
        let spy = SpyReceiver()
        let sut = UserNotificationsReceiver(receiver: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
}

private extension UserNotificationsReceiver {
    @discardableResult
    func receiveNotification() -> UNNotificationPresentationOptions? {
        let anyNotification = try? InstanceHelper.create(UNNotification.self)
        
        var receivedOption: UNNotificationPresentationOptions?
        userNotificationCenter(UNUserNotificationCenter.current(),
                               willPresent: anyNotification!,
                               withCompletionHandler: { option in receivedOption = option })
        
        return receivedOption
    }
}

private extension ReceiverNotificationTests {
    func assertNotificationType(with type: UNNotificationPresentationOptions?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(type, .banner, file: file, line: line)
    }
}

extension UNNotificationPresentationOptions: CustomStringConvertible {
    public var description: String {
        if rawValue == 16 {
            return "banner"
        }
        
        return "unknown Option"
    }
}
