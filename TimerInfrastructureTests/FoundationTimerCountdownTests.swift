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
    private var timerDelivery: StartCoundownCompletion?
    
    private var currentTimer: Timer?
    
    init(startingSet: LocalElapsedSeconds, nextSet: LocalElapsedSeconds) {
        self.setA = startingSet
        self.setB = nextSet
        self.currentSet = startingSet
    }
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        invalidatesTimer()
        state = .running
        timerDelivery = completion
        createTimer()
    }
    
    private func createTimer() {
        currentTimer = Timer.init(timeInterval: 1, target: self, selector: #selector(elapsedCompletion), userInfo: nil, repeats: true)
        RunLoop.current.add(currentTimer!, forMode: .common)
    }
    
    @objc
    private func elapsedCompletion() {
        let endDate = currentSet.endDate.adding(seconds: -elapsedTimeInterval)
        
        guard endDate.timeIntervalSince(currentSet.startDate) > 0 else {
            setA = currentSet
            currentSet = setB
            setB = setA
            return
        }
        
        elapsedTimeInterval += 1
        
        let elapsed = currentSet.addingElapsedSeconds(elapsedTimeInterval)
        timerDelivery?(.success(elapsed))
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
    
    func test_start_deliversOneSecondElapsedFromTheSetOfStartingSecondsAndChangesStateToRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        expect(sut: sut, toDeliver: [startSet.addingElapsedSeconds(1)],
               andChangesStateTo: .running)
    }
    
    func test_start_deliversTwoSecondsElapsedFromTheSetOfStartingSecondsAndChangesStateToRunning() {
        let fixedDate = Date()
        let startSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 2))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        expect(sut: sut,
               toDeliver: [startSet.addingElapsedSeconds(1), startSet.addingElapsedSeconds(2)],
               andChangesStateTo: .running)
    }
    
    func test_startTwice_doesNotChangeStateOfRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        assertsStartCountdownTwiceChangesStateToRunning(sut: sut)
    }
    
    // MARK: - Helpers
    private func assertsStartCountdownTwiceChangesStateToRunning(sut: FoundationTimerCountdown) {
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
        let sut = FoundationTimerCountdown(startingSet: startingSet, nextSet: nextSet)
        
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

        wait(for: [expectation], timeout: Double(deliverExpectation.count) + 0.1)
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
