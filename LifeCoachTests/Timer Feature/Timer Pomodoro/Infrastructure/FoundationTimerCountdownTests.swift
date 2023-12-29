import LifeCoach
import XCTest

final class FoundationTimerCountdownTests: XCTestCase {
    
    func test_init_stateIsStop() {
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
    
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_start_setsCorrectTimerValues() {
        let startSet = createAnyTimerSet()
        let samples: [(deliveryCount: Int, expectedTimerValues: (state: TimerCountdownState, set: LocalTimerSet))] = [
            (deliveryCount: 2, expectedTimerValues: (state: TimerCountdownState.running,
                                                   set: startSet.adding(0.001))),
            (deliveryCount: 3, expectedTimerValues: (state: TimerCountdownState.running,
                                                   set: startSet.adding(0.002)))
        ]
        
        samples.forEach { sample in
            let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
            
            starts(sut: sut, waitUntilDeliveryCount: sample.deliveryCount)
            
            assertTimerSet(sample.expectedTimerValues.set, state: sample.expectedTimerValues.state, from: sut)
        }
    }
    
    func test_start_deliversCorrectTimerValues() {
        let fixedDate = Date()
        let startSet1 = createAnyTimerSet()
        let startSet2 = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        
        let samples: [(startSet: LocalTimerSet, expected: [LocalTimerSet])] = [
            (startSet: startSet1, expected: [startSet1, startSet1.adding(0.001)]),
            (startSet: startSet2, expected: [startSet2, startSet2.adding(0.001), startSet2.adding(0.002)])
        ]
        
        samples.forEach { sample in
            let sut = makeSUT(startingSet: sample.startSet, nextSet: createAnyTimerSet())
            
            expect(sut: sut, toDeliver: sample.expected)
        }
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
        
        var receivedLocalTimerSets = [LocalTimerSet]()
        
        sut.startCountdown() { result in
            if case let .success((timerSet, _)) = result {
                receivedLocalTimerSets.append(timerSet)
            }
        }
        XCTAssertEqual(receivedLocalTimerSets, [startSet])
        
        sut.stopCountdown()
        XCTAssertEqual(receivedLocalTimerSets, [startSet, startSet])
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
        
        let receivedLocalTimerSets = receivedLocalTimerSetsOnRunningState(from: sut, when: {
            sut.pauseCountdown()
        })

        XCTAssertEqual(receivedLocalTimerSets, [startSet, startSet])
    }
    
    func test_skip_onStopState_deliversNextTimerSet() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        let receivedLocalTimerSets = receivedLocalTimerSetsOnSkip(from: sut)
        
        XCTAssertEqual(receivedLocalTimerSets, [nextSet])
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
        
        let receivedLocalTimerSetsOnRunningState = receivedLocalTimerSetsOnRunningState(from: sut, when: {
            let receivedLocalTimerSetsOnSkip = receivedLocalTimerSetsOnSkip(from: sut)
            XCTAssertEqual(receivedLocalTimerSetsOnSkip, [nextSet])
        })
        XCTAssertEqual(receivedLocalTimerSetsOnRunningState, [startingSet])
    }
    
    // MARK: - Helpers
    private func starts(sut: TimerCountdown, waitUntilDeliveryCount count: Int) {
        let expectation = expectation(description: "wait for start countdown to deliver time.")
        expectation.expectedFulfillmentCount = count
        
        sut.startCountdown(completion: { _ in
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 0.1)
        invalidatesTimer(on: sut)
    }
    
    private func assertTimerSet(_ timerSet: LocalTimerSet, state expectedState: TimerCountdownState, from sut: TimerCountdown, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.state, expectedState, file: file, line: line)
        XCTAssertEqual(sut.currentSetElapsedTime, timerSet.elapsedSeconds, "should have expected \(timerSet.elapsedSeconds) but got \(sut.currentSetElapsedTime) current set.", file: file, line: line)
        XCTAssertEqual(sut.currentTimerSet, timerSet, file: file, line: line)
    }
    
    private func receivedLocalTimerSetsOnSkip(from sut: TimerCountdown) -> [LocalTimerSet] {
        var receivedLocalTimerSets = [LocalTimerSet]()
        let expectation = expectation(description: "wait for skip countdown to deliver time.")
        sut.skipCountdown() { result in
            if case let .success((timerSet, _)) = result {
                receivedLocalTimerSets.append(timerSet)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
        return receivedLocalTimerSets
    }
    
    private func receivedLocalTimerSetsOnRunningState(from sut: TimerCountdown, when action: () -> Void) -> [LocalTimerSet] {
        var receivedLocalTimerSets = [LocalTimerSet]()
        sut.startCountdown() { result in
            if case let .success((timerSet, _)) = result {
                receivedLocalTimerSets.append(timerSet)
            }
        }

        action()
        
        return receivedLocalTimerSets
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
        var receivedLocalTimerSets = [LocalTimerSet]()
        let expectation = expectation(description: "wait for start countdown to deliver time.")
        expectation.expectedFulfillmentCount = deliverExpectation.count
        
        sut.startCountdown() { result in
            if case let .success((timerSet, _)) = result {
                receivedLocalTimerSets.append(timerSet)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        invalidatesTimer(on: sut)

        XCTAssertEqual(receivedLocalTimerSets, deliverExpectation, file: file, line: line)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date? = nil) -> LocalTimerSet {
        makeAnyTimerSet(startDate: startDate, endDate: endDate ?? startDate.adding(seconds: 1)).local
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalTimerSet {
        makeAnyTimerSet(seconds: elapsedSeconds, startDate: startDate, endDate: endDate).local
    }
    
    private func invalidatesTimer(on sut: TimerCountdown) {
        (sut as? FoundationTimerCountdown)?.invalidatesTimer()
    }
}

extension TimerCountdown {
    func commitFinishedTimer() {
        startCountdown(completion: { _ in })
    }
}
