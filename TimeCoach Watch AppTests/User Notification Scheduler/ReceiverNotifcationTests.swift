import XCTest
import LifeCoach
import UserNotifications

class UserNotificationsReceiver: NSObject, UNUserNotificationCenterDelegate {
    private let receiver: TimerNotificationReceiver
    
    init(receiver: TimerNotificationReceiver) {
        self.receiver = receiver
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        receiver.receiveNotification()
        
        completionHandler(.banner)
    }
}

final class ReceiverNotificationTests: XCTestCase {
    func test_init_shouldNotSendMessageToReceiver() {
        let spy = SpyReceiver()
        let _ = UserNotificationsReceiver(receiver: spy)
        
        XCTAssertEqual(spy.receiveCallCount, 0)
    }
    
    func test_receive_sendsMessageToReceiver() {
        let spy = SpyReceiver()
        let sut = UserNotificationsReceiver(receiver: spy)
        
        sut.receiveNotification()
        
        XCTAssertEqual(spy.receiveCallCount, 1)
    }
    
    func test_receive_receivesCorrectNotificationType() {
        let spy = SpyReceiver()
        let sut = UserNotificationsReceiver(receiver: spy)
        
        let receivedNoticicationType = sut.receiveNotification()
        
        assertNotificationType(with: receivedNoticicationType)
    }
    
    private class SpyReceiver: TimerNotificationReceiver {
        private(set) var receiveCallCount = 0
        
        func receiveNotification() {
            receiveCallCount += 1
        }
    }
}

private final class FakeKeyedArchiver: NSKeyedArchiver {
    override func decodeObject(forKey _: String) -> Any { "" }
    override func decodeInt64(forKey key: String) -> Int64 { 0 }
}

private extension UserNotificationsReceiver {
    @discardableResult
    func receiveNotification() -> UNNotificationPresentationOptions? {
        let anyNotification = UNNotification(coder: FakeKeyedArchiver())
        
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
