import XCTest

class PomodoroTimer {
    
    init(timer: TimerSpy) {
        
    }
}

class TimerSpy {
    private(set) var getTimeCallCount = 0
}

final class PomodoroUseCaseTests: XCTestCase {

    func test_init_doesNotSendsMessageGetTimeOnInit() {
        let timerHelper = TimerSpy()
        let _ = PomodoroTimer(timer: timerHelper)
        XCTAssertEqual(timerHelper.getTimeCallCount, 0)
    }
}
