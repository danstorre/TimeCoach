import LifeCoach
import XCTest

class FoundationTimerCountdown {
    typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    
    enum TimerState {
        case pause
        case running
    }
    
    private(set) var state: TimerState = .pause
    private var setA: LocalElapsedSeconds
    private var setB: LocalElapsedSeconds
    private var currentSet: LocalElapsedSeconds
    private var elapsedTimeInterval: TimeInterval = 0
    private let incrementing: Double
    private var timerDelivery: StartCoundownCompletion?
    
    private var currentTimer: Timer?
    
    init(startingSet: LocalElapsedSeconds, nextSet: LocalElapsedSeconds, incrementing: Double = 1.0) {
        self.setA = startingSet
        self.setB = nextSet
        self.currentSet = startingSet
        self.incrementing = incrementing
    }
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        invalidatesTimer()
        state = .running
        timerDelivery = completion
        createTimer()
    }
    
    func stop() {
        invalidatesTimer()
        state = .pause
        timerDelivery?(.success(currentSet))
    }
    
    func pause() {
        invalidatesTimer()
        state = .pause
    }
    
    func skipCountdown(completion: @escaping StartCoundownCompletion) {
        timerDelivery = completion
        executeNextSet()
    }
    
    private func createTimer() {
        currentTimer = Timer.init(timeInterval: incrementing, target: self, selector: #selector(elapsedCompletion), userInfo: nil, repeats: true)
        RunLoop.current.add(currentTimer!, forMode: .common)
    }
    
    @objc
    private func elapsedCompletion() {
        guard hasNotHitThreshold() else {
            executeNextSet()
            return
        }
        
        elapsedTimeInterval += incrementing
        
        let elapsed = currentSet.addingElapsedSeconds(elapsedTimeInterval)
        timerDelivery?(.success(elapsed))
    }
    
    private func hasNotHitThreshold() -> Bool {
        let endDate = currentSet.endDate.adding(seconds: -elapsedTimeInterval)
        return endDate.timeIntervalSince(currentSet.startDate) > 0
    }
    
    private func executeNextSet() {
        invalidatesTimer()
        state = .pause
        setA = currentSet
        currentSet = setB
        timerDelivery?(.success(setB))
        setB = setA
    }
    
    func invalidatesTimer() {
        currentTimer?.invalidate()
    }
}

private extension LocalElapsedSeconds {
    func addingElapsedSeconds(_ seconds: Double) -> LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}

final class FoundationTimerCountdownTests: XCTestCase {
    
    func test_init_stateIsPaused() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        XCTAssertEqual(sut.state, .pause)
    }
    
    func test_start_deliversOneMilliSecondElapsedFromTheStartingSetAndChangesStateToRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        expect(sut: sut, toDeliver: [startSet.addingElapsedSeconds(0.001)],
               andChangesStateTo: .running)
    }
    
    func test_start_deliversTwoMilliSecondsElapsedFromTheStartingSetAndChangesStateToRunning() {
        let fixedDate = Date()
        let startSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        expect(sut: sut,
               toDeliver: [startSet.addingElapsedSeconds(0.001), startSet.addingElapsedSeconds(0.002)],
               andChangesStateTo: .running)
    }
    
    func test_startTwice_doesNotChangeStateOfRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        assertsStartCountdownTwiceKeepsStateToRunning(sut: sut)
    }
    
    func test_start_onThresholdHit_DeliversNextTimerSetAndChangesStateToPause() {
        let fixedDate = Date()
        let startingSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.001))
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        expect(sut: sut, toDeliver: [startingSet.addingElapsedSeconds(0.001), nextSet], andChangesStateTo: .pause)
    }
    
    func test_stop_OnPauseState_DoesNotChangeStateFromPause() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        sut.stop()
        
        XCTAssertEqual(sut.state, .pause)
    }
    
    func test_stop_onRunningStateDeliversNonElapsedSecondsFromTheCurrentTimerSet() {
        let startingSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startingSet, nextSet: createAnyTimerSet())
        
        let receivedElapsedSeconds = receivedElapsedSecondsOnRunningState(from: sut, when: {
            sut.stop()
        })
        
        XCTAssertEqual(sut.state, .pause)
        XCTAssertEqual(receivedElapsedSeconds, [startingSet])
    }
    
    func test_pause_OnPauseState_DoesNotChangeStateFromPause() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        sut.pause()
        
        XCTAssertEqual(sut.state, .pause)
    }
    
    func test_pause_onRunningState_doesNotDeliverAnyMoreTimesAndChangesStateToPause() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        let receivedElapsedSeconds = receivedElapsedSecondsOnRunningState(from: sut, when: {
            sut.pause()
        })

        XCTAssertEqual(sut.state, .pause)
        XCTAssertEqual(receivedElapsedSeconds, [])
    }
    
    func test_skip_onPauseState_doesNotChangesPauseStateAndDeliversNextTimerSet() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        var receivedElapsedSeconds = receivedElapsedSecondsOnSkip(from: sut)
        
        XCTAssertEqual(sut.state, .pause)
        XCTAssertEqual(receivedElapsedSeconds, [nextSet])
    }
    
    // MARK: - Helpers
    private func receivedElapsedSecondsOnSkip(from sut: FoundationTimerCountdown) -> [LocalElapsedSeconds] {
        var receivedElapsedSeconds = [LocalElapsedSeconds]()
        sut.skipCountdown() { result in
            if case let .success(deliveredElapsedSeconds) = result {
                receivedElapsedSeconds.append(deliveredElapsedSeconds)
            }
        }
        return receivedElapsedSeconds
    }
    
    private func receivedElapsedSecondsOnRunningState(from sut: FoundationTimerCountdown, when action: () -> Void) -> [LocalElapsedSeconds] {
        var receivedElapsedSeconds = [LocalElapsedSeconds]()
        sut.startCountdown() { result in
            if case let .success(deliveredElapsedSeconds) = result {
                receivedElapsedSeconds.append(deliveredElapsedSeconds)
            }
        }

        action()
        
        return receivedElapsedSeconds
    }
    
    private func assertsStartCountdownTwiceKeepsStateToRunning(sut: FoundationTimerCountdown) {
        assertsStartCountdownChangesStateToRunning(sut: sut)
        assertsStartCountdownChangesStateToRunning(sut: sut)
        sut.invalidatesTimer()
    }
    
    private func assertsStartCountdownChangesStateToRunning(sut: FoundationTimerCountdown) {
        sut.startCountdown(completion: { _ in })

        XCTAssertEqual(sut.state, .running)
    }
    
    private func makeSUT(startingSet: LocalElapsedSeconds, nextSet: LocalElapsedSeconds,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> FoundationTimerCountdown {
        let sut = FoundationTimerCountdown(startingSet: startingSet, nextSet: nextSet, incrementing: 0.001)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(sut: FoundationTimerCountdown, toDeliver deliverExpectation: [LocalElapsedSeconds],
                        andChangesStateTo expectedState: FoundationTimerCountdown.TimerState,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var receivedElapsedSeconds = [LocalElapsedSeconds]()
        let expectation = expectation(description: "wait for start countdown to deliver time.")
        expectation.expectedFulfillmentCount = deliverExpectation.count
        sut.startCountdown() { result in
            if case let .success(deliveredElapsedSeconds) = result {
                receivedElapsedSeconds.append(deliveredElapsedSeconds)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        sut.invalidatesTimer()

        XCTAssertEqual(receivedElapsedSeconds, deliverExpectation, file: file, line: line)
        XCTAssertEqual(sut.state, expectedState, file: file, line: line)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date()) -> LocalElapsedSeconds {
        createTimerSet(0, startDate: startDate, endDate: startDate.adding(seconds: 1))
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
