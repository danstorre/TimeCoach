import LifeCoach
import XCTest

class PomodoroLocalTimer {
    private var handler: ((LocalElapsedSeconds) -> Void)? = nil
    private var timer: Timer? = nil
    private var invalidationTimer: Timer? = nil
    
    private var elapsedTimeInterval: TimeInterval = 0
    private var startDate: Date
    private var finishDate: Date
    
    init(startDate: Date, primaryInterval: TimeInterval) {
        self.startDate = startDate
        self.finishDate = startDate.adding(seconds: primaryInterval)
    }
    
    func startCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        handler = completion
        timer = createTimer()
        invalidationTimer = createInvalidationTimer(endDate: finishDate)
        
        RunLoop.current.add(invalidationTimer!, forMode: .default)
    }
    
    func pauseCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        invalidateTimers()
        let elapsed = LocalElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        completion(elapsed)
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
                                          startDate: startDate,
                                          endDate: finishDate)
        handler?(elapsed)
    }
}

final class PomodoroLocalTimerTests: XCTestCase {
    
    func test_startCountdown_deliversTimerAfterOneSecond() {
        var received = [LocalElapsedSeconds]()
        let expectation = expectation(description: "waits for timer to finish twice")
        expectation.expectedFulfillmentCount = 2
        
        let primary: TimeInterval = 3.0
        let now = Date.now
        let end = now.adding(seconds: primary)
        let sut = makeSUT(startDate: now, primaryInterval: primary)
        
        sut.startCountdown() { elapsed in
            received.append(elapsed)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        assertsThatStartCoutdownDeliverTimeAfterOneSecond(of: received, from: now, to: end, count: 2)
    }
    
    func test_pauseCountdown_stopsDeliveringTime() {
        let primary: TimeInterval = 10.0
        let now = Date.now
        let end = now.adding(seconds: primary)
        let sut = makeSUT(startDate: now, primaryInterval: primary)
        
        var receivedTime = [LocalElapsedSeconds]()
        let expectation = expectation(description: "waits for timer to finish three times")
        expectation.expectedFulfillmentCount = 3
        sut.startCountdown() { elapsed in
            receivedTime.append(elapsed)
            expectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            sut.pauseCountdown { elapsed in
                receivedTime.append(elapsed)
                expectation.fulfill()
            }
        })
        
        wait(for: [expectation], timeout: 3)
        
        assertsThatStartCoutdownDeliverTimeAfterOneSecond(of: receivedTime, from: now, to: end, count: 3)
        
        let expectedLocal = LocalElapsedSeconds(2, startDate: now, endDate: end)
        XCTAssertEqual(receivedTime[2], expectedLocal)
    }
    
    // MARK: - helpers
    private func makeSUT(startDate: Date, primaryInterval: TimeInterval,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> PomodoroLocalTimer {
        let sut = PomodoroLocalTimer(startDate: startDate, primaryInterval: primaryInterval)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        invalidateTimerOnFinish(sut: sut, file: file, line: line)
        return sut
    }
    
    func invalidateTimerOnFinish(sut: PomodoroLocalTimer,
                                 file: StaticString = #filePath,
                                 line: UInt = #line) {
        addTeardownBlock { [weak sut] in
            sut?.invalidateTimers()
        }
    }
    
    private func assertsThatStartCoutdownDeliverTimeAfterOneSecond(
        of received: [LocalElapsedSeconds], from now: Date, to end: Date, count: Int,
        file: StaticString = #filePath, line: UInt = #line)
    {
        XCTAssertEqual(received.count, count, file: file, line: line)
        
        XCTAssertEqual(received[0].elapsedSeconds, 1, file: file, line: line)
        XCTAssertEqual(received[1].elapsedSeconds, 2, file: file, line: line)
        
        XCTAssertEqual(received[0].startDate, now, file: file, line: line)
        XCTAssertEqual(received[1].startDate, now, file: file, line: line)
        
        XCTAssertEqual(received[0].endDate, end, file: file, line: line)
        XCTAssertEqual(received[1].endDate, end, file: file, line: line)
    }
}
