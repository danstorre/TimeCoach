import LifeCoach
import XCTest

final class FoundationTimerCountdownTests: XCTestCase {
    
    func test_init_stateIsStop() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
    
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_start_afterOneMilliSecondElapsedFromTheStartingSetsCorrectCurrentTimerState() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        let expectation = expectation(description: "wait for start countdown to deliver time.")
        expectation.expectedFulfillmentCount = 2
        
        sut.startCountdown(completion: { _ in
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.1)
        invalidatesTimer(on: sut)
        
        assertTimerSet(startSet.adding(0.001), state: .running, from: sut)
    }
    
    func test_start_afterTwoMilliSecondsElapsedFromTheStartingSetsCorrectCurrentTimerState() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        let expectation = expectation(description: "wait for start countdown to deliver time.")
        expectation.expectedFulfillmentCount = 3
        
        sut.startCountdown(completion: { _ in
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.1)
        invalidatesTimer(on: sut)
        
        assertTimerSet(startSet.adding(0.002), state: .running, from: sut)
    }
    
    func test_start_deliversOneMilliSecondElapsedFromTheStartingSet() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        expect(sut: sut, toDeliver: [startSet, startSet.adding(0.001)])
    }
    
    func test_start_deliversTwoMilliSecondsElapsedFromTheStartingSet() {
        let fixedDate = Date()
        let startSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())

        expect(sut: sut, toDeliver: [startSet, startSet.adding(0.001), startSet.adding(0.002)])
    }
    
    func test_start_afterFinishTheFirstSetTimerDoesNotChangeState() {
        let fixedDate = Date()
        let startSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.001))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        let finishedStartSet = startSet.adding(0.001)
        
        expect(sut: sut, toDeliver: [startSet, finishedStartSet])
        sut.commitFinishedTimer()
        
        assertTimerSet(finishedStartSet, state: .stop, from: sut)
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
        
        expect(sut: sut, toDeliver: [startingSet, startingSet.adding(0.001)])
    }
    
    func test_stop_onStopState_deliversCurrentSet() {
        let currentSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: currentSet, nextSet: createAnyTimerSet())
        
        sut.stopCountdown()
        
        expect(sut: sut, toDeliver: [currentSet])
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
            if case let .success((timerSet, _)) = result {
                receivedElapsedSeconds.append(timerSet)
            }
        }
        XCTAssertEqual(receivedElapsedSeconds, [startSet])
        
        sut.stopCountdown()
        XCTAssertEqual(receivedElapsedSeconds, [startSet, startSet])
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
    
    func test_pause_onRunningState_deliversCurrentState() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        let receivedElapsedSeconds = receivedElapsedSecondsOnRunningState(from: sut, when: {
            sut.pauseCountdown()
        })

        XCTAssertEqual(receivedElapsedSeconds, [startSet, startSet])
    }
    
    func test_skip_onStopState_deliversNextTimerSet() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        let receivedElapsedSeconds = receivedElapsedSecondsOnSkip(from: sut)
        
        XCTAssertEqual(receivedElapsedSeconds, [nextSet])
    }
    
    func test_skip_onStopState_doesNotChangesStopStateResetsTimer() {
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
        XCTAssertEqual(receivedElapsedSecondsOnRunningState, [startingSet])
    }
    
    // MARK: - Helpers
    private func assertTimerSet(_ timerSet: LocalTimerSet, state expectedState: TimerCountdownState, from sut: TimerCountdown, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.state, expectedState, file: file, line: line)
        XCTAssertEqual(sut.currentSetElapsedTime, timerSet.elapsedSeconds, "should have expected \(timerSet.elapsedSeconds) but got \(sut.currentSetElapsedTime) current set.", file: file, line: line)
        XCTAssertEqual(sut.currentTimerSet, timerSet, file: file, line: line)
    }
    
    private func receivedElapsedSecondsOnSkip(from sut: TimerCountdown) -> [LocalTimerSet] {
        var receivedElapsedSeconds = [LocalTimerSet]()
        let expectation = expectation(description: "wait for skip countdown to deliver time.")
        sut.skipCountdown() { result in
            if case let .success((timerSet, _)) = result {
                receivedElapsedSeconds.append(timerSet)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
        return receivedElapsedSeconds
    }
    
    private func receivedElapsedSecondsOnRunningState(from sut: TimerCountdown, when action: () -> Void) -> [LocalTimerSet] {
        var receivedElapsedSeconds = [LocalTimerSet]()
        sut.startCountdown() { result in
            if case let .success((timerSet, _)) = result {
                receivedElapsedSeconds.append(timerSet)
            }
        }

        action()
        
        return receivedElapsedSeconds
    }
    
    private func assertsStartCountdownTwiceKeepsStateToRunning(sut: TimerCountdown) {
        assertsStartCountdownChangesStateToRunning(sut: sut)
        assertsStartCountdownChangesStateToRunning(sut: sut)
        invalidatesTimer(on: sut)
    }
    
    private func assertsStartCountdownChangesStateToRunning(sut: TimerCountdown) {
        sut.startCountdown(completion: { _ in })

        XCTAssertEqual(sut.state, .running)
    }
    
    private func makeSUT(startingSet: LocalTimerSet, nextSet: LocalTimerSet,
                         incrementing: Double = 0.001,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> TimerCountdown {
        let sut = FoundationTimerCountdown(startingSet: startingSet, nextSet: nextSet, incrementing: incrementing)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(sut: TimerCountdown, toDeliver deliverExpectation: [LocalTimerSet],
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var receivedElapsedSeconds = [LocalTimerSet]()
        let expectation = expectation(description: "wait for start countdown to deliver time.")
        expectation.expectedFulfillmentCount = deliverExpectation.count
        
        sut.startCountdown() { result in
            if case let .success((timerSet, _)) = result {
                receivedElapsedSeconds.append(timerSet)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        invalidatesTimer(on: sut)

        XCTAssertEqual(receivedElapsedSeconds, deliverExpectation, file: file, line: line)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date? = nil) -> LocalTimerSet {
        createTimerSet(0, startDate: startDate, endDate: endDate ?? startDate.adding(seconds: 1))
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalTimerSet {
        LocalTimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
    
    private func invalidatesTimer(on sut: TimerCountdown) {
        (sut as? FoundationTimerCountdown)?.invalidatesTimer()
    }
}

extension LocalTimerSet: CustomStringConvertible {
    public var description: String {
        "elapsed seconds: \(elapsedSeconds), startDate: \(startDate), endDate: \(endDate)"
    }
}

extension TimerCountdown {
    func commitFinishedTimer() {
        startCountdown(completion: { _ in })
    }
}
