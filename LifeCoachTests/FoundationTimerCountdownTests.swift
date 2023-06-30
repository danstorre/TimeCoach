import LifeCoach
import XCTest

final class FoundationTimerCountdownTests: XCTestCase {
    
    func test_init_stateIsStop() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
    }
    
    func test_start_deliversOneMilliSecondElapsedFromTheStartingSetAndChangesStateToRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        expect(sut: sut, toDeliver: [startSet.addingElapsedSeconds(0.001)],
               andChangesStateTo: .running,
               andElapsedTime: 0.001)
    }
    
    func test_start_deliversTwoMilliSecondsElapsedFromTheStartingSetAndChangesStateToStop() {
        let fixedDate = Date()
        let startSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        expect(sut: sut,
               toDeliver: [startSet.addingElapsedSeconds(0.001), startSet.addingElapsedSeconds(0.002)],
               andChangesStateTo: .stop,
               andElapsedTime: 0.002)
    }
    
    func test_start_afterFinishDoesNotChangeState() {
        let fixedDate = Date()
        let startSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.001))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        expect(sut: sut,
               toDeliver: [startSet.addingElapsedSeconds(0.001)],
               andChangesStateTo: .stop,
               andElapsedTime: 0.001)
        
        sut.startCountdown(completion: { _ in })
        
        XCTAssertEqual(sut.state, .stop)
    }
    
    func test_startTwice_doesNotChangeStateOfRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        assertsStartCountdownTwiceKeepsStateToRunning(sut: sut)
    }
    
    func test_start_onThresholdHit_DeliversZeroTimeResetsTimerAndChangesStateToStop() {
        let fixedDate = Date()
        let startingSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.001))
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        expect(sut: sut, toDeliver: [startingSet.addingElapsedSeconds(0.001)],
               andChangesStateTo: .stop,
               andElapsedTime: 0.001)
    }
    
    func test_stop_onStopState_doesNotChangeStateFromStop() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
        
        sut.stopCountdown()
        
        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
    }
    
    func test_stop_OnPauseState_changesStateToStop() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
        
        sut.pauseCountdown()
        XCTAssertEqual(sut.state, .pause)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
        
        sut.stopCountdown()
        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
    }
    
    func test_stop_onRunningState_ResetsTimerAndChangesStateToStop() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())

        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
        
        sut.startCountdown() { _ in }
        XCTAssertEqual(sut.state, .running)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
        
        sut.stopCountdown()
        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
    }
    
    func test_stop_afterStartCountdown_deliversCurrentSet() {
        let fixedDate = Date()
        let startSet = LocalElapsedSeconds(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet(), incrementing: 0.001)
        
        var receivedElapsedSeconds = [LocalElapsedSeconds]()
        
        sut.startCountdown() { result in
            if case let .success(elapsedSeconds) = result {
                receivedElapsedSeconds.append(elapsedSeconds)
            }
        }
        XCTAssertEqual(receivedElapsedSeconds, [])
        
        sut.stopCountdown()
        XCTAssertEqual(receivedElapsedSeconds, [startSet])
    }
    
    func test_pause_OnPauseState_DoesNotChangeStateFromPause() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        sut.pauseCountdown()
        
        XCTAssertEqual(sut.state, .pause)
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
    }
    
    func test_pause_onRunningState_doesNotDeliverAnyMoreTimesAndChangesStateToPause() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        let receivedElapsedSeconds = receivedElapsedSecondsOnRunningState(from: sut, when: {
            sut.pauseCountdown()
        })

        XCTAssertEqual(sut.state, .pause)
        XCTAssertEqual(receivedElapsedSeconds, [])
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
    }
    
    func test_skip_onPauseState_doesNotChangesStopStateResetsTimerAndDeliversNextTimerSet() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        let receivedElapsedSeconds = receivedElapsedSecondsOnSkip(from: sut)
        
        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(receivedElapsedSeconds, [nextSet])
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
    }
    
    func test_skip_onRunningState_changesStateToStopResetsTimerAndSendsNextTimerSet() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        let receivedElapsedSecondsOnRunningState = receivedElapsedSecondsOnRunningState(from: sut, when: {
            let receivedElapsedSecondsOnSkip = receivedElapsedSecondsOnSkip(from: sut)
            XCTAssertEqual(sut.state, .stop)
            XCTAssertEqual(receivedElapsedSecondsOnSkip, [nextSet])
            XCTAssertEqual(sut.currentSetElapsedTime, 0)
        })

        XCTAssertEqual(sut.state, .stop)
        XCTAssertEqual(receivedElapsedSecondsOnRunningState, [])
        XCTAssertEqual(sut.currentSetElapsedTime, 0)
    }
    
    // MARK: - Helpers
    private func receivedElapsedSecondsOnSkip(from sut: TimerCoutdown) -> [LocalElapsedSeconds] {
        var receivedElapsedSeconds = [LocalElapsedSeconds]()
        let expectation = expectation(description: "wait for skip countdown to deliver time.")
        sut.skipCountdown() { result in
            if case let .success(deliveredElapsedSeconds) = result {
                receivedElapsedSeconds.append(deliveredElapsedSeconds)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
        return receivedElapsedSeconds
    }
    
    private func receivedElapsedSecondsOnRunningState(from sut: TimerCoutdown, when action: () -> Void) -> [LocalElapsedSeconds] {
        var receivedElapsedSeconds = [LocalElapsedSeconds]()
        sut.startCountdown() { result in
            if case let .success(deliveredElapsedSeconds) = result {
                receivedElapsedSeconds.append(deliveredElapsedSeconds)
            }
        }

        action()
        
        return receivedElapsedSeconds
    }
    
    private func assertsStartCountdownTwiceKeepsStateToRunning(sut: TimerCoutdown) {
        assertsStartCountdownChangesStateToRunning(sut: sut)
        assertsStartCountdownChangesStateToRunning(sut: sut)
        invalidatesTimer(on: sut)
    }
    
    private func assertsStartCountdownChangesStateToRunning(sut: TimerCoutdown) {
        sut.startCountdown(completion: { _ in })

        XCTAssertEqual(sut.state, .running)
    }
    
    private func makeSUT(startingSet: LocalElapsedSeconds, nextSet: LocalElapsedSeconds,
                         incrementing: Double = 0.001,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> TimerCoutdown {
        let sut = FoundationTimerCountdown(startingSet: startingSet, nextSet: nextSet, incrementing: incrementing)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(sut: TimerCoutdown, toDeliver deliverExpectation: [LocalElapsedSeconds],
                        andChangesStateTo expectedState: TimerState,
                        andElapsedTime expectedElapsedTime: TimeInterval,
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
        invalidatesTimer(on: sut)

        XCTAssertEqual(receivedElapsedSeconds, deliverExpectation, file: file, line: line)
        XCTAssertEqual(sut.state, expectedState, file: file, line: line)
        XCTAssertEqual(sut.currentSetElapsedTime, expectedElapsedTime, "should have expected \(expectedElapsedTime) but got \(sut.currentSetElapsedTime) current set.", file: file, line: line)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date()) -> LocalElapsedSeconds {
        createTimerSet(0, startDate: startDate, endDate: startDate.adding(seconds: 1))
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
    
    private func invalidatesTimer(on sut: TimerCoutdown) {
        (sut as? FoundationTimerCountdown)?.invalidatesTimer()
    }
}

extension LocalElapsedSeconds: CustomStringConvertible {
    public var description: String {
        "elapsed seconds: \(elapsedSeconds)"
    }
}
