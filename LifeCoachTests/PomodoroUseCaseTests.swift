import XCTest

class PomodoroTimer {
    private let timer: TimerSpy
    private let timeReceiver: (Error) -> Void
    
    enum Error: Swift.Error {
        case timerError
    }
    
    init(timer: TimerSpy, timeReceiver: @escaping (Error) -> Void) {
        self.timer = timer
        self.timeReceiver = timeReceiver
    }
    
    func start() {
        timer.startCountdown() { [unowned self] error in
            self.timeReceiver(.timerError)
        }
    }
}

class TimerSpy {
    private(set) var startCountdownCallCount = 0
    
    private var startCountdownCompletions = [(Error) -> Void]()
    
    func startCountdown(completion: @escaping (Error) -> Void) {
        startCountdownCallCount += 1
        startCountdownCompletions.append(completion)
    }
    
    func failsTimerWith(error: NSError, at index: Int = 0) {
        startCountdownCompletions[index](error)
    }
}

final class PomodoroUseCaseTests: XCTestCase {

    func test_init_doesNotSendsMessageToTimerCountdownOnInit() {
        let (_, spy) = makeSUT()
        XCTAssertEqual(spy.startCountdownCallCount, 0)
    }
    
    func test_start_sendsStartMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.start()
        
        XCTAssertEqual(spy.startCountdownCallCount, 1)
    }
    
    func test_start_deliversTimerErrorOnTimerCountdownError() {
        var receivedError: PomodoroTimer.Error?
        let (sut, spy) = makeSUT(timeReceiver: { error in
            receivedError = error
        })
        
        sut.start()
        
        spy.failsTimerWith(error: anyNSError())
        
        XCTAssertEqual(receivedError, .timerError)
    }
    
    // MARK: - Helpers
    private func makeSUT(timeReceiver: ((PomodoroTimer.Error) -> Void)? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (PomodoroTimer, TimerSpy) {
        let spy = TimerSpy()
        let sut = PomodoroTimer(timer: spy, timeReceiver: timeReceiver ?? { _ in })
        
        trackForMemoryLeak(instance: spy, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 1)
    }
}
