import LifeCoach
import XCTest

class PomodoroLocalTimer {
    private var handler: ((LocalElapsedSeconds) -> Void)? = nil
    private var timer: Timer? = nil
    private var invalidationTimer: Timer? = nil
    
    private var elapsedTimeInterval: TimeInterval = 0
    private var startDate: Date?
    private var finishDate: Date?
    
    func startCountdown(from date: Date, endDate: Date, completion: @escaping (LocalElapsedSeconds) -> Void) {
        self.startDate = date
        self.finishDate = endDate
        
        handler = completion
        timer = createTimer()
        invalidationTimer = createInvalidationTimer(endDate: endDate)
        
        RunLoop.current.add(invalidationTimer!, forMode: .default)
    }
    
    private func createTimer() -> Timer {
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(elapsedCompletion),
                             userInfo: nil,
                             repeats: true)
    }
    
    private func createInvalidationTimer(endDate: Date) -> Timer {
        Timer(
            fire: endDate,
            interval: 0,
            repeats: false,
            block: { [weak self] timer in
                self?.invalidateTimers()
        })
    }
    
    @objc
    func invalidateTimers() {
        invalidationTimer?.invalidate()
        timer?.invalidate()
    }
    
    @objc
    func elapsedCompletion() {
        elapsedTimeInterval += 1
        let elapsed = LocalElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate ?? Date(),
                                          endDate: finishDate ?? Date())
        handler?(elapsed)
    }
}

final class PomodoroLocalTimerTests: XCTestCase {
    
    func test_startCountdown_deliversTimerAfterOneSecond() {
        var received = [LocalElapsedSeconds]()
        let expectation = expectation(description: "waits for timer to finish twice")
        expectation.expectedFulfillmentCount = 2
        let sut = PomodoroLocalTimer()
        let now = Date.now
        let end = now.adding(seconds: 3)
        
        sut.startCountdown(from: now,
                           endDate: end) { elapsed in
            received.append(elapsed)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        assertsThatStartCoutdownDeliverTimeAfterOneSecond(of: received, from: now, to: end)
    }
    
    // MARK: - helpers
    private func assertsThatStartCoutdownDeliverTimeAfterOneSecond(of received: [LocalElapsedSeconds],
                                                                   from now: Date,
                                                                   to end: Date) {
        XCTAssertEqual(received.count, 2)
        
        XCTAssertEqual(received[0].elapsedSeconds, 1)
        XCTAssertEqual(received[1].elapsedSeconds, 2)

        XCTAssertEqual(received[0].startDate, now)
        XCTAssertEqual(received[1].startDate, now)
        
        XCTAssertEqual(received[0].endDate, end)
        XCTAssertEqual(received[1].endDate, end)
    }
}
