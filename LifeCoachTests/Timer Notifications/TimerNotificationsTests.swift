import XCTest

class TimerNotificationScheduler {
    init(scheduler: Spy) {}
}

class Spy {
    private(set) var scheduleCallCount = 0
}

final class TimerNotificationsTests: XCTestCase {

    func test_init_doesNotScheduleTimer() {
        let spy = Spy()
        let _ = TimerNotificationScheduler(scheduler: spy)
        
        XCTAssertEqual(spy.scheduleCallCount, 0)
    }
}
