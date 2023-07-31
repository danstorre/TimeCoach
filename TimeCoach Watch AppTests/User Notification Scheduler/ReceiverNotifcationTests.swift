import XCTest
import UserNotifications

class UserNotificationsReceiver {
    private let receiver: MockReceiver
    
    init(receiver: MockReceiver) {
        self.receiver = receiver
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        receiver.receiveNotification()
    }
}

class MockReceiver {
    private(set) var receiveCallCount = 0
    
    func receiveNotification() {
        receiveCallCount += 1
    }
}

final class ReceiverNotificationTests: XCTestCase {
    func test_init_shouldNotSendMessageToReceiver() {
        let spy = MockReceiver()
        let _ = UserNotificationsReceiver(receiver: spy)
        
        XCTAssertEqual(spy.receiveCallCount, 0)
    }
    
    func test_receive_sendsMessageToReceiver() {
        let spy = MockReceiver()
        let sut = UserNotificationsReceiver(receiver: spy)
        
        sut.receiveNotification()
        
        XCTAssertEqual(spy.receiveCallCount, 1)
    }
}

private final class FakeKeyedArchiver: NSKeyedArchiver {
    override func decodeObject(forKey _: String) -> Any { "" }
    override func decodeInt64(forKey key: String) -> Int64 { 0 }
}

extension UserNotificationsReceiver {
    func receiveNotification() {
        let anyNotification = UNNotification(coder: FakeKeyedArchiver())
        userNotificationCenter(UNUserNotificationCenter.current(),
                               willPresent: anyNotification!,
                               withCompletionHandler: { _ in})
    }
}
