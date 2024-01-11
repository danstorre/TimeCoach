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
    
    func test_start_deliversTimerSetsOnTimerCountdownSuccessDelivery() {
        var recievedResult: PomodoroTimer.Result?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            recievedResult = result
        })
        let startTime = Date()
        let expectedDeliveredTime = makeDeliveredTime(1, startDate: startTime, endDate: startTime.adding(seconds: .pomodoroInSeconds))
        
        sut.start()
        spy.startDelivers(localState: (expectedDeliveredTime.local, TimerCountdownStateValues.running))
        
        assert(recievedResult: recievedResult!, ToBe: .success(TimerState(timerSet: expectedDeliveredTime.model,
                                                                          state: .running)))
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
    
    func test_skip_deliversTimerSetsOnTimerCountdownSuccessDelivery() {
        var recievedResult: PomodoroTimer.Result?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            recievedResult = result
        })
        let startTime = Date()
        let expectedDeliveredTime = makeDeliveredTime(1, startDate: startTime, endDate: startTime.adding(seconds: .pomodoroInSeconds))
        
        sut.skip()
        spy.skipDelivers(localState: (expectedDeliveredTime.local, TimerCountdownStateValues.stop))
        
        assert(recievedResult: recievedResult!, ToBe: .success(TimerState(timerSet: expectedDeliveredTime.model,
                                                                          state: .stop)))
    }
    
    func test_start_doesNotDeliverTimerSetsAfterSUTHasBeenDeallocated() {
        var recievedResult: PomodoroTimer.Result?
        let spy = TimerSpy()
        var sut: PomodoroTimer? = PomodoroTimer(timer: spy, timeReceiver: { result in
            recievedResult = result
        })
        
        sut?.start()
        sut = nil
        spy.startDelivers(localState: (localSet: createAnyLocalTimerSets(), state: TimerCountdownStateValues.running))
        
        XCTAssertNil(recievedResult)
    }
    
    func test_skip_doesNotDeliverTimerSetsAfterSUTHasBeenDeallocated() {
        var recievedResult: PomodoroTimer.Result?
        let spy = TimerSpy()
        var sut: PomodoroTimer? = PomodoroTimer(timer: spy, timeReceiver: { result in
            recievedResult = result
        })
        
        sut?.skip()
        sut = nil
        spy.skipDelivers(localState: (createAnyLocalTimerSets(), TimerCountdownStateValues.stop))
        
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
    
    private func createAnyLocalTimerSets() -> LocalTimerSet {
        LocalTimerSet(1, startDate: Date(), endDate: Date())
    }
    
    private func makeDeliveredTime(_ elapsedSeconds: TimeInterval,
                                   startDate: Date,
                                   endDate: Date) -> (model: TimerSet, local: LocalTimerSet) {
        let model = TimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
        let local = LocalTimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
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
    
    private class TimerSpy: TimerCountdown {
        var currentState: TimerCountDownState {
            .init(state: .stop, currentTimerSet: currentTimerSet)
        }
        
        var currentTimerSet: LifeCoach.LocalTimerSet { .init(0, startDate: Date(), endDate: Date())}
        var currentSetElapsedTime: TimeInterval { 0 }
        var state: LifeCoach.TimerCountdownStateValues { returningState }
        
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
        
        func startDelivers(localState: (localSet: LifeCoach.LocalTimerSet, state: LifeCoach.TimerCountdownStateValues), at index: Int = 0) {
            startCountdownCompletions[index](.success((localState.localSet, localState.state)))
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
        private var returningState: LifeCoach.TimerCountdownStateValues = .pause
        
        func skipCountdown(completion: @escaping SkipCountdownCompletion) {
            messagesReceived.append(.skip)
            
            skipCountdownCompletions.append(completion)
        }
        
        func failsSkipTimerWith(error: NSError, at index: Int = 0) {
            skipCountdownCompletions[index](.failure(error))
        }
        
        func skipDelivers(localState: (localSet: LifeCoach.LocalTimerSet, state: LifeCoach.TimerCountdownStateValues), at index: Int = 0) {
            returningState = localState.state
            skipCountdownCompletions[index](.success((localState.localSet, localState.state)))
        }
    }
}
