import LifeCoach
import XCTest

class FoundationTimerCountdown {
    typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    
    enum TimerState {
        case pause
    }
    
    var state: TimerState { .pause }
    private let startingSeconds: LocalElapsedSeconds
    
    init(startingSeconds: LocalElapsedSeconds) {
        self.startingSeconds = startingSeconds
    }
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        completion(.success(startingSeconds.addingElapsedSeconds(1)))
    }
}

private extension LocalElapsedSeconds {
    func addingElapsedSeconds(_ seconds: Double) -> LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}

final class FoundationTimerCountdownTests: XCTestCase {
    func test_init_stateIsPaused() {
        let sut = FoundationTimerCountdown(startingSeconds: createAnyLocalElapsedSeconds())
        XCTAssertEqual(sut.state, .pause)
    }
    
    func test_start_deliversOneSecondElapsedFromTheSetOfStartingSeconds() {
        let fixedDate = Date()
        let startingSeconds = createElapsedSeconds(0, startDate: fixedDate, endDate: fixedDate.addingTimeInterval(.pomodoroInSeconds))
        let sut = FoundationTimerCountdown(startingSeconds: startingSeconds)
        
        var receivedElapsedSeconds = [LocalElapsedSeconds]()
        let expectation = expectation(description: "wait for start countdown to deliver time.")
        sut.startCountdown() { result in
            if case let .success(deliveredElapsedSeconds) = result {
                receivedElapsedSeconds.append(deliveredElapsedSeconds)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(receivedElapsedSeconds, [startingSeconds.addingElapsedSeconds(1)])
    }
    
    // MARK: - Helpers
    private func createElapsedSeconds(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: startDate)
    }
    
    private func createAnyLocalElapsedSeconds(date: Date = Date()) -> LocalElapsedSeconds {
        LocalElapsedSeconds(0, startDate: date, endDate: date.adding(seconds: 1))
    }
}
