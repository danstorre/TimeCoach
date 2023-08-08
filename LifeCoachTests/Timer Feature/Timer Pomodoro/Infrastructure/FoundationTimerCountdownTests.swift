import LifeCoach
import XCTest

final class FoundationTimerCountdownTests: XCTestCase {
    
    func test_init_stateIsStop() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
    
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_start_deliversOneMilliSecondElapsedFromTheStartingSetAndChangesStateToRunning() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        expect(sut: sut, toDeliver: [startSet.adding(0.001)],
               andChangesStateTo: .running,
               andElapsedTime: 0.001)
    }
    
    func test_start_deliversTwoMilliSecondsElapsedFromTheStartingSetAndChangesStateToStop() {
        let fixedDate = Date()
        let startSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        expect(sut: sut,
               toDeliver: [startSet.adding(0.001), startSet.adding(0.002)],
               andChangesStateTo: .stop,
               andElapsedTime: 0.002)
    }
    
    func test_start_afterFinishTheFirstSetTimerDoesNotChangeState() {
        let fixedDate = Date()
        let startSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.001))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        expect(sut: sut,
               toDeliver: [startSet.adding(0.001)],
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
        
        expect(sut: sut, toDeliver: [startingSet.adding(0.001)],
               andChangesStateTo: .stop,
               andElapsedTime: 0.001)
    }
    
    func test_stop_onStopState_doesNotChangeStateFromStop() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        sut.stopCountdown()
        
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_stop_OnPauseState_changesStateToStop() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        sut.pauseCountdown()
        
        sut.stopCountdown()
        
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_stop_onRunningState_ResetsTimerAndChangesStateToStop() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        assertTimerSet(startSet, state: .stop, from: sut)
        
        sut.startCountdown() { _ in }
        assertTimerSet(startSet, state: .running, from: sut)
        
        sut.stopCountdown()
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_stop_afterStartCountdown_deliversCurrentSet() {
        let fixedDate = Date()
        let startSet = LocalTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet(), incrementing: 0.001)
        
        var receivedElapsedSeconds = [LocalTimerSet]()
        
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
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        sut.pauseCountdown()
        
        assertTimerSet(startSet, state: .pause, from: sut)
    }
    
    func test_pause_onRunningState_changesStateToPause() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        sut.startCountdown() { _ in }
        
        sut.pauseCountdown()

        assertTimerSet(startSet, state: .pause, from: sut)
    }
    
    func test_pause_onRunningState_doesNotDeliverAnyMoreTimes() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        let receivedElapsedSeconds = receivedElapsedSecondsOnRunningState(from: sut, when: {
            sut.pauseCountdown()
        })

        XCTAssertEqual(receivedElapsedSeconds, [])
    }
    
    func test_skip_onPauseState_deliversNextTimerSet() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        let receivedElapsedSeconds = receivedElapsedSecondsOnSkip(from: sut)
        
        XCTAssertEqual(receivedElapsedSeconds, [nextSet])
    }
    
    func test_skip_onPauseState_doesNotChangesStopStateResetsTimer() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        sut.skipCountdown { _ in }
        
        assertTimerSet(nextSet, state: .stop, from: sut)
    }
    
    func test_skip_onRunningState_changesStateToStopResetsTimer() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        sut.startCountdown { _ in }
        
        sut.skipCountdown { _ in }
        
        assertTimerSet(nextSet, state: .stop, from: sut)
    }
    
    func test_skip_onRunningState_sendsNextTimerSet() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        let receivedElapsedSecondsOnRunningState = receivedElapsedSecondsOnRunningState(from: sut, when: {
            let receivedElapsedSecondsOnSkip = receivedElapsedSecondsOnSkip(from: sut)
            XCTAssertEqual(receivedElapsedSecondsOnSkip, [nextSet])
        })
        XCTAssertEqual(receivedElapsedSecondsOnRunningState, [])
    }
    
    // MARK: - Helpers
    private func assertTimerSet(_ timerSet: LocalTimerSet, state: TimerCoutdownState, from sut: TimerCoutdown, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.state, state, file: file, line: line)
        XCTAssertEqual(sut.currentSetElapsedTime, 0, file: file, line: line)
        XCTAssertEqual(sut.currentTimerSet, timerSet, file: file, line: line)
    }
    
    private func receivedElapsedSecondsOnSkip(from sut: TimerCoutdown) -> [LocalTimerSet] {
        var receivedElapsedSeconds = [LocalTimerSet]()
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
    
    private func receivedElapsedSecondsOnRunningState(from sut: TimerCoutdown, when action: () -> Void) -> [LocalTimerSet] {
        var receivedElapsedSeconds = [LocalTimerSet]()
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
    
    private func makeSUT(startingSet: LocalTimerSet, nextSet: LocalTimerSet,
                         incrementing: Double = 0.001,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> TimerCoutdown {
        let sut = FoundationTimerCountdown(startingSet: startingSet, nextSet: nextSet, incrementing: incrementing)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(sut: TimerCoutdown, toDeliver deliverExpectation: [LocalTimerSet],
                        andChangesStateTo expectedState: TimerCoutdownState,
                        andElapsedTime expectedElapsedTime: TimeInterval,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var receivedElapsedSeconds = [LocalTimerSet]()
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
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date? = nil) -> LocalTimerSet {
        createTimerSet(0, startDate: startDate, endDate: endDate ?? startDate.adding(seconds: 1))
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalTimerSet {
        LocalTimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
    
    private func invalidatesTimer(on sut: TimerCoutdown) {
        (sut as? FoundationTimerCountdown)?.invalidatesTimer()
    }
}

extension LocalTimerSet: CustomStringConvertible {
    public var description: String {
        "elapsed seconds: \(elapsedSeconds), startDate: \(startDate), endDate: \(endDate)"
    }
}
