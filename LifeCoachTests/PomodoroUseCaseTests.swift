import XCTest
import LifeCoach

final class PomodoroUseCaseTests: XCTestCase {
    func test_init_doesNotSendsMessageToTimerCountdownOnInit() {
        let (_, spy) = makeSUT()
        XCTAssertEqual(spy.messagesReceived, [])
    }
    
    func test_start_sendsStartMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.start()
        
        XCTAssertEqual(spy.messagesReceived, [.start])
    }
    
    func test_start_deliversTimerErrorOnTimerCountdownError() {
        var recievedResult: PomodoroTimer.Result?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            recievedResult = result
        })
        
        sut.start()
        spy.failsStartTimerWith(error: anyNSError())
        
        assert(recievedResult: recievedResult!, ToBe: .failure(.timerError))
    }
    
    func test_start_sendsStopMessageToTimerCountdownOnTimerCountdownError() {
        let (sut, spy) = makeSUT()
        
        sut.start()
        
        spy.failsStartTimerWith(error: anyNSError())
        
        XCTAssertEqual(spy.messagesReceived, [.start, .stop])
    }
    
    func test_start_deliversElapsedSecondsOnTimerCountdownSuccessDelivery() {
        var recievedResult: PomodoroTimer.Result?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            recievedResult = result
        })
        let startTime = Date()
        let expectedDeliveredTime = makeDeliveredTime(1, startDate: startTime, endDate: startTime.adding(seconds: .pomodoroInSeconds))
        
        sut.start()
        spy.startDelivers(time: expectedDeliveredTime.local)
        
        assert(recievedResult: recievedResult!, ToBe: .success(expectedDeliveredTime.model))
    }
    
    func test_pause_sendsPauseMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.pause()
        
        XCTAssertEqual(spy.messagesReceived, [.pause])
    }
    
    func test_stop_sendsStopMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.stop()
        
        XCTAssertEqual(spy.messagesReceived, [.stop])
    }
    
    func test_skip_sendsSkipMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.skip()
        
        XCTAssertEqual(spy.messagesReceived, [.skip])
    }
    
    func test_skip_deliversTimerErrorOnTimerCountdownError() {
        var recievedResult: PomodoroTimer.Result?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            recievedResult = result
        })
        
        sut.skip()
        spy.failsSkipTimerWith(error: anyNSError())
        
        assert(recievedResult: recievedResult!, ToBe: .failure(.timerError))
    }
    
    func test_skip_sendsStopMessageToTimerCountdownOnTimerCountdownError() {
        let (sut, spy) = makeSUT()
        
        sut.skip()
        spy.failsSkipTimerWith(error: anyNSError())
        
        XCTAssertEqual(spy.messagesReceived, [.skip, .stop])
    }
    
    func test_skip_deliversElapsedSecondsOnTimerCountdownSuccessDelivery() {
        var recievedResult: PomodoroTimer.Result?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            recievedResult = result
        })
        let startTime = Date()
        let expectedDeliveredTime = makeDeliveredTime(1, startDate: startTime, endDate: startTime.adding(seconds: .pomodoroInSeconds))
        
        sut.skip()
        spy.skipDelivers(time: expectedDeliveredTime.local)
        
        assert(recievedResult: recievedResult!, ToBe: .success(expectedDeliveredTime.model))
    }
    
    func test_start_doesNotDeliverElapsedSecondsAfterSUTHasBeenDeallocated() {
        var recievedResult: PomodoroTimer.Result?
        let spy = TimerSpy()
        var sut: PomodoroTimer? = PomodoroTimer(timer: spy, timeReceiver: { result in
            recievedResult = result
        })
        
        sut?.start()
        sut = nil
        spy.startDelivers(time: createAnyLocalElapsedSeconds())
        
        XCTAssertNil(recievedResult)
    }
    
    // MARK: - Helper
    private func assert(recievedResult result: PomodoroTimer.Result, ToBe expectedResult: PomodoroTimer.Result, file: StaticString = #filePath, line: UInt = #line) {
        switch (result, expectedResult) {
        case let (.success(timeDelivered), .success(expectedTimeDelivered)):
            XCTAssertEqual(timeDelivered, expectedTimeDelivered, file: file, line: line)
        case let (.failure(error), .failure(expectedError)):
            XCTAssertEqual(error, expectedError, file: file, line: line)
        case (.failure, .success), (.success, .failure):
            XCTFail("expected \(expectedResult), got \(result)", file: file, line: line)
        }
    }
    
    private func createAnyLocalElapsedSeconds() -> LocalElapsedSeconds {
        LocalElapsedSeconds(1, startDate: Date(), endDate: Date())
    }
    
    private func makeDeliveredTime(_ elapsedSeconds: TimeInterval,
                                   startDate: Date,
                                   endDate: Date) -> (model: ElapsedSeconds, local: LocalElapsedSeconds) {
        let model = ElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
        let local = LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
        return (model, local)
    }
    
    private func makeSUT(timeReceiver: ((PomodoroTimer.Result) -> Void)? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (RegularTimer, TimerSpy) {
        let spy = TimerSpy()
        let sut = PomodoroTimer(timer: spy, timeReceiver: timeReceiver ?? { _ in })
        
        trackForMemoryLeak(instance: spy, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 1)
    }
    
    private class TimerSpy: TimerCoutdown {
        private(set) var messagesReceived = [TimerCountdownMessages]()
        enum TimerCountdownMessages: Equatable, CustomStringConvertible {
            case start
            case stop
            case pause
            case skip
            
            var description: String {
                switch self {
                case .start: return "start"
                case .stop: return "stop"
                case .pause: return "pause"
                case .skip: return "skip"
                }
            }
        }
        // MARK: - StartCoundown methods
        private var startCountdownCompletions = [StartCoundownCompletion]()
        
        func startCountdown(completion: @escaping StartCoundownCompletion) {
            messagesReceived.append(.start)
            startCountdownCompletions.append(completion)
        }
        
        func failsStartTimerWith(error: NSError, at index: Int = 0) {
            startCountdownCompletions[index](.failure(error))
        }
        
        func startDelivers(time localTime: LocalElapsedSeconds, at index: Int = 0) {
            startCountdownCompletions[index](.success(localTime))
        }
        
        // MARK: - StopCountdown methods
        func stopCountdown() {
            messagesReceived.append(.stop)
        }
        
        // MARK: - PauseCoutdown methods
        func pauseCountdown() {
            messagesReceived.append(.pause)
        }
        
        // MARK: - SkipCoutdown methods
        private var skipCountdownCompletions = [SkipCountdownCompletion]()
        
        func skipCountdown(completion: @escaping SkipCountdownCompletion) {
            messagesReceived.append(.skip)
            
            skipCountdownCompletions.append(completion)
        }
        
        func failsSkipTimerWith(error: NSError, at index: Int = 0) {
            skipCountdownCompletions[index](.failure(error))
        }
        
        func skipDelivers(time localTime: LocalElapsedSeconds, at index: Int = 0) {
            skipCountdownCompletions[index](.success(localTime))
        }
    }
}
