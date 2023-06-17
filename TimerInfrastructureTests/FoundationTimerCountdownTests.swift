import LifeCoach
import XCTest

class FoundationTimerCountdown {
    typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    
    enum TimerState {
        case pause
        case running
    }
    
    private(set) var state: TimerState = .pause
    private let startingSet: LocalElapsedSeconds
    private var elapsedTimeInterval: TimeInterval = 0
    private var timerDelivery: StartCoundownCompletion?
    
    private var currentTimer: Timer?
    
    init(startingSet: LocalElapsedSeconds) {
        self.startingSet = startingSet
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
        elapsedTimeInterval += 1
        let elapsed = startingSet.addingElapsedSeconds(elapsedTimeInterval)
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
        let sut = makeSUT(startingSet: createAnyTimerSet())
        XCTAssertEqual(sut.state, .pause)
    }
    
    func test_start_deliversOneSecondElapsedFromTheSetOfStartingSecondsAndChangesStateToRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet)
        
        expect(sut: sut, toDeliver: [startSet.addingElapsedSeconds(1)],
               andChangesStateTo: .running)
    }
    
    func test_start_deliversTwoSecondsElapsedFromTheSetOfStartingSecondsAndChangesStateToRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet)

        expect(sut: sut,
               toDeliver: [startSet.addingElapsedSeconds(1), startSet.addingElapsedSeconds(2)],
               andChangesStateTo: .running)
    }
    
    func test_startTwice_doesNotChangeStateOfRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet)

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
    
    private func makeSUT(startingSet: LocalElapsedSeconds, file: StaticString = #filePath,
                         line: UInt = #line) -> FoundationTimerCountdown {
        let sut = FoundationTimerCountdown(startingSet: startingSet)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(sut: FoundationTimerCountdown, toDeliver deliverExpectation: [LocalElapsedSeconds],
                        andChangesStateTo expectedState: FoundationTimerCountdown.TimerState) {
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

        XCTAssertEqual(receivedElapsedSeconds, deliverExpectation)
        XCTAssertEqual(sut.state, expectedState)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date()) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: startDate, endDate: startDate.adding(seconds: 1))
    }
}
