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

    func test_init_doesNotSendsMessageToTimerCountdownOnInit() {
        let (_, spy) = makeSUT()
        XCTAssertEqual(spy.getTimeCallCount, 0)
    }
    
    func test_start_sendsStartMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.start()
        
        XCTAssertEqual(spy.getTimeCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (PomodoroTimer, TimerSpy) {
        let spy = TimerSpy()
        let sut = PomodoroTimer(timer: spy)
        
        trackForMemoryLeak(instance: spy, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, spy)
    }
}
