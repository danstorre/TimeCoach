@testable import LifeCoach
import XCTest

class UserNotificationsReceiver {
    init(receiver: MockReceiver) {
        
    }
}

class MockReceiver {
    private(set) var receiveCallCount = 0
}

final class ReceiverNotifcationTests: XCTestCase {
    func test_init_shouldNotSendMessageToReceiver() {
        let spy = MockReceiver()
        let sut = UserNotificationsReceiver(receiver: spy)
        
        XCTAssertEqual(spy.receiveCallCount, 0)
    }
}
