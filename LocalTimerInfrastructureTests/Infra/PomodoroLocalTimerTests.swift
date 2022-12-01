import LifeCoach
import XCTest

class PomodoroLocalTimer {
    private var handler: ((LocalElapsedSeconds) -> Void)? = nil
    private var timer: Timer? = nil
    private var invalidationTimer: Timer? = nil
    
    private var elapsedTimeInterval: TimeInterval = 0
    private var startDate: Date
    private var finishDate: Date
    
    private var primaryInterval: TimeInterval
    private var secondaryTime: TimeInterval
    
    private var threshold: TimeInterval = 0
    
    private let currentDate: () -> Date
    
    init(currentDate: @escaping () -> Date = Date.init,
         startDate: Date,
         primaryInterval: TimeInterval,
         secondaryTime: TimeInterval) {
        self.startDate = startDate
        self.finishDate = startDate.adding(seconds: primaryInterval)
        self.threshold = primaryInterval
        self.primaryInterval = primaryInterval
        self.secondaryTime = secondaryTime
        self.currentDate = currentDate
    }
    
    func startCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        invalidateTimers()
        handler = completion
        timer = createTimer()
    }
    
    func pauseCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        invalidateTimers()
        let elapsed = LocalElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        completion(elapsed)
    }
    
    func skipCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        invalidateTimers()
        elapsedTimeInterval = 0
        
        if threshold == primaryInterval {
            threshold = secondaryTime
        } else {
            threshold = primaryInterval
        }
        
        let now = currentDate()
        startDate = now
        finishDate = now.adding(seconds: threshold)
        let elapsed = LocalElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        completion(elapsed)
    }
    
    func stopCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        invalidateTimers()
        elapsedTimeInterval = 0
        
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
    
    @objc
    func invalidateTimers() {
        invalidationTimer?.invalidate()
        timer?.invalidate()
    }
    
    @objc
    func elapsedCompletion() {
        guard elapsedTimeInterval < threshold else {
            return
        }
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
    
    func test_start_onPause_resumesDeliveringTime() {
        let sut = makeSUT(primaryInterval: 5)
        
        let expectation = expectation(description: "waits for expectation to be fullied twice")
        expectation.expectedFulfillmentCount = 3
        
        let deadLine = DispatchTime.now()
        sut.startCountdown() { elapsed in
            expectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadLine + 2.1, execute: {
            sut.pauseCountdown { elapsed in
                XCTAssertEqual(elapsed.elapsedSeconds, 2)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                sut.startCountdown() { elapsed in
                    XCTAssertEqual(elapsed.elapsedSeconds, 3)
                    expectation.fulfill()
                }
            })
        })
        
        wait(for: [expectation], timeout: 5.3)
    }
    
    func test_start_shouldNotDeliverMoreTime_afterReachingThresholdInterval() {
        let sut = makeSUT(primaryInterval: 1)
        var received = [LocalElapsedSeconds]()
        let expectation = expectation(description: "waits for expectation to be fullfil only once")
        expectation.expectedFulfillmentCount = 1
         
        sut.startCountdown() { elapsed in
            received.append(elapsed)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(received.count, 1)
    }
    
    func test_skip_shouldNotDeliverMoreTime_afterMeetingSecondaryInterval() {
        let primaryInterval: TimeInterval = 2.0
        let secondaryInterval: TimeInterval = 1.0
        let sut = makeSUT(primaryInterval: primaryInterval,
                          secondaryTime: secondaryInterval)

        skipExpecting(sut: sut, toReceivedElapsedTimes: 1, withInterval: secondaryInterval)
        skipExpecting(sut: sut, toReceivedElapsedTimes: 2, withInterval: primaryInterval)
    }
    
    func test_skip_deliversSecondaryInterval() {
        let primaryInterval: TimeInterval = 2.0
        let secondaryInterval: TimeInterval = 1.0
        let now = Date.now
        let sut = makeSUT(currentDate: { now },
                          primaryInterval: primaryInterval,
                          secondaryTime: secondaryInterval)
        var received = [LocalElapsedSeconds]()
        let expectation = expectation(description: "waits for expectation to be fullfil only once")
        
        sut.skipCountdown() { elapsed in
            received.append(elapsed)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
        let expectedLocal = LocalElapsedSeconds(0, startDate: now, endDate: now.adding(seconds: secondaryInterval))
        
        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received[0], expectedLocal)
    }
    
    func test_start_afterSkip_deliversCorrectSecondaryInterval() {
        let primaryInterval: TimeInterval = 4.0
        let secondaryInterval: TimeInterval = 1.0
        let now = Date.now
        let currentDate = { now }
        let sut = makeSUT(currentDate: currentDate,
                          primaryInterval: primaryInterval,
                          secondaryTime: secondaryInterval)
        var received = [LocalElapsedSeconds]()
        let expectation = expectation(description: "waits for expectation to be fullfil only once")
        
        sut.skipCountdown() { _ in }
        
        sut.startCountdown() { elapsed in
            received.append(elapsed)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
        let expectedLocal = LocalElapsedSeconds(1,
                                                startDate: currentDate(),
                                                endDate: currentDate().adding(seconds: secondaryInterval))
        
        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received[0], expectedLocal)
    }
    
    func test_stop_deliversResettedCurrentInterval() {
        let primaryInterval: TimeInterval = 4.0
        let secondaryInterval: TimeInterval = 1.0
        let now = Date.now
        let currentDate = { now }
        let sut = makeSUT(currentDate: currentDate,
                          primaryInterval: primaryInterval,
                          secondaryTime: secondaryInterval)
        
        let expectation = expectation(description: "waits for expectation to be fullfil only once")
        var received = [LocalElapsedSeconds]()
        
        sut.startCountdown() { elapsed in
            received.append(elapsed)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
        sut.stopCountdown { elapsed in
            received.append(elapsed)
        }
        
        let expectedLocal = LocalElapsedSeconds(0,
                                                startDate: currentDate(),
                                                endDate: currentDate().adding(seconds: primaryInterval))
        XCTAssertEqual(received.count, 2)
        XCTAssertEqual(received[1], expectedLocal)
    }
    
    func test_stop_shouldStopReceivingTimeUpdates() {
        let primaryInterval: TimeInterval = 4.0
        let secondaryInterval: TimeInterval = 1.0
        let now = Date.now
        let currentDate = { now }
        let sut = makeSUT(currentDate: currentDate,
                          primaryInterval: primaryInterval,
                          secondaryTime: secondaryInterval)
        
        let expectation = expectation(description: "waits for expectation to be fullfil only once")
        var received = [LocalElapsedSeconds]()
        
        sut.startCountdown() { elapsed in
            received.append(elapsed)
        }
        
        sut.stopCountdown { elapsed in
            received.append(elapsed)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 3)
        
        XCTAssertEqual(received.count, 1)
    }
    
    // MARK: - helpers
    private func skipExpecting(sut: PomodoroLocalTimer,
                               toReceivedElapsedTimes expectedTimes: Int,
                               withInterval interval: TimeInterval,
                               file: StaticString = #filePath,
                               line: UInt = #line
    ) {
        var received = [LocalElapsedSeconds]()
        
        let expectation = expectation(description: "waits for interval expectation to be fullfil only once")
        expectation.expectedFulfillmentCount = 1
         
        sut.skipCountdown() { _ in
        }
        
        sut.startCountdown() { elapsed in
            received.append(elapsed)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: {
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(received.count, expectedTimes, file: file, line: line)
    }

    private func makeSUT(currentDate: @escaping () -> Date = { Date.now },
                         startDate: Date = .now, primaryInterval: TimeInterval = 1.0,
                         secondaryTime: TimeInterval = 1.0,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> PomodoroLocalTimer {
        let sut = PomodoroLocalTimer(
            currentDate: currentDate,
            startDate: startDate,
            primaryInterval: primaryInterval,
            secondaryTime: secondaryTime
        )
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
