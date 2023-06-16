import XCTest

class PomodoroTimer {
    private let timer: TimerSpy
    
    init(timer: TimerSpy) {
        self.timer = timer
    }
    
    func start() {
        timer.startCountdown()
    }
}

class TimerSpy {
    private(set) var getTimeCallCount = 0
    
    func startCountdown() {
        getTimeCallCount += 1
    }
}

final class PomodoroUseCaseTests: XCTestCase {

    func test_init_doesNotSendsMessageGetTimeOnInit() {
        let timerHelper = TimerSpy()
        let _ = PomodoroTimer(timer: timerHelper)
        XCTAssertEqual(timerHelper.getTimeCallCount, 0)
    }
    
    func test_start_sendsStartMessageToTimerCountdown() {
        let timerHelper = TimerSpy()
        let pomodoroTimer = PomodoroTimer(timer: timerHelper)
        
        pomodoroTimer.start()
        
        XCTAssertEqual(timerHelper.getTimeCallCount, 1)
    }
}
