import LifeCoach
import XCTest

class FoundationTimerCountdown {
    typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    
    enum TimerState {
        case pause
        case running
    }
    
    private(set) var state: TimerState = .pause
    private let startingSeconds: LocalElapsedSeconds
    private var elapsedTimeInterval: TimeInterval = 0
    private var timerDelivery: StartCoundownCompletion?
    
    private var currentTimer: Timer?
    
    init(startingSeconds: LocalElapsedSeconds) {
        self.startingSeconds = startingSeconds
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
        let elapsed = startingSeconds.addingElapsedSeconds(elapsedTimeInterval)
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
        let sut = makeSUT(startingSeconds: createAnyLocalElapsedSeconds())
        XCTAssertEqual(sut.state, .pause)
    }
    
    func test_start_deliversOneSecondElapsedFromTheSetOfStartingSecondsAndChangesStateToRunning() {
        let startingSeconds = createAnyLocalElapsedSeconds()
        let sut = makeSUT(startingSeconds: startingSeconds)
        
        expect(sut: sut, toDeliver: [startingSeconds.addingElapsedSeconds(1)], andChangesStateTo: .running)
    }
    
    func test_start_deliversTwoSecondsElapsedFromTheSetOfStartingSecondsAndChangesStateToRunning() {
        let startingSeconds = createAnyLocalElapsedSeconds()
        let sut = makeSUT(startingSeconds: startingSeconds)

        expect(sut: sut, toDeliver: [startingSeconds.addingElapsedSeconds(1), startingSeconds.addingElapsedSeconds(2)],     andChangesStateTo: .running)
    }
    
    func test_startTwice_doesNotChangeStateOfRunning() {
        let startingSeconds = createAnyLocalElapsedSeconds()
        let sut = makeSUT(startingSeconds: startingSeconds)

        sut.startCountdown(completion: { _ in })

        XCTAssertEqual(sut.state, .running)

        sut.startCountdown(completion: { _ in })

        XCTAssertEqual(sut.state, .running)
        
        sut.invalidatesTimer()
    }
    
    // MARK: - Helpers
    private func makeSUT(startingSeconds: LocalElapsedSeconds, file: StaticString = #filePath,
                         line: UInt = #line) -> FoundationTimerCountdown {
        let sut = FoundationTimerCountdown(startingSeconds: startingSeconds)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(sut: FoundationTimerCountdown, toDeliver: [LocalElapsedSeconds],
                        andChangesStateTo expectedState: FoundationTimerCountdown.TimerState) {
        var receivedElapsedSeconds = [LocalElapsedSeconds]()
        let expectation = expectation(description: "wait for start countdown to deliver time.")
        expectation.expectedFulfillmentCount = toDeliver.count
        sut.startCountdown() { result in
            if case let .success(deliveredElapsedSeconds) = result {
                receivedElapsedSeconds.append(deliveredElapsedSeconds)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: Double(toDeliver.count) + 0.1)
        sut.invalidatesTimer()

        XCTAssertEqual(receivedElapsedSeconds, toDeliver)
        XCTAssertEqual(sut.state, expectedState)
    }
    
    private func createElapsedSeconds(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: startDate)
    }
    
    private func createAnyLocalElapsedSeconds(date: Date = Date()) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: 1))
    }
}
