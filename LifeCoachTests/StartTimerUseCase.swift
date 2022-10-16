import XCTest

class TimerStarter {
    init(timer: TimerSpy) {}
}

class TimerSpy {
    var messageCount = 0
}

final class StartTimerUseCase: XCTestCase {

    func test_init_doesNotSendsMessageToTimer() {
        let timer = TimerSpy()
        let _ = TimerStarter(timer: timer)
        
        XCTAssertEqual(timer.messageCount, 0)
    }
}
