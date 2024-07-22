import LifeCoach
import XCTest

final class FoundationTimerCountdownTests: XCTestCase {
    
    func test_init_stateIsStop() {
        let startSet = createAnyTimerSet()
        let (sut, _) = makeSUT2(startingSet: startSet, nextSet: createAnyTimerSet())
    
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_start_setsCorrectTimerValues() {
        let incrementing = 0.001
        let startSet = createAnyTimerSet()
        let samples: [(pulseCount: Int, expectedTimerValues: (state: TimerCountdownStateValues, set: TimerCountdownSet))] = [
            (pulseCount: 1, expectedTimerValues: (state: TimerCountdownStateValues.running,
                                                   set: startSet.adding(incrementing * 1))),
            (pulseCount: 2, expectedTimerValues: (state: TimerCountdownStateValues.running,
                                                   set: startSet.adding(incrementing * 2)))
        ]
        
        samples.forEach { sample in
            let (sut, spy) = makeSUT2(startingSet: startSet,
                                      nextSet: createAnyTimerSet(),
                                      incrementing: incrementing)
            
            starts(sut: sut, spy: spy, incrementingValue: incrementing,
                   waitUntilPulseCount: sample.pulseCount)
            
            assertTimerSet(sample.expectedTimerValues.set, state: sample.expectedTimerValues.state, from: sut)
        }
    }
    
    func test_startTwice_doesNotChangeStateOfRunning() {
        let startSet = createAnyTimerSet()
        let (sut, _) = makeSUT2(startingSet: startSet, nextSet: createAnyTimerSet())

        assertsStartCountdownTwiceKeepsStateToRunning(sut: sut)
    }
    
    func test_start_onSetFinishChangesStateWithCorrectTimerValues() {
        let startDate = Date()
        let incrementing = 0.001
        let finishDate = startDate.adding(seconds: incrementing)
        let startSet = createTimerSet(0, startDate: startDate, endDate: finishDate)
        let (sut, spy) = makeSUT2(startingSet: startSet, 
                                  nextSet: createAnyTimerSet(),
                                  incrementing: incrementing)
        
        starts(sut: sut, spy: spy, incrementingValue: incrementing, waitUntilPulseCount: 1)
        
        assertTimerSet(startSet.adding(incrementing), state: .stop, from: sut)
    }
    
    func test_stop_onStopState_deliversCorrectState() {
        let startSet = createAnyTimerSet()
        let (sut, _) = makeSUT2(startingSet: startSet, nextSet: createAnyTimerSet())
        
        sut.stopCountdown()
        
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_stop_onRunningState_resetsTimerAndChangesStateToStop() {
        let startSet = createAnyTimerSet()
        let (sut, _) = makeSUT2(startingSet: startSet, nextSet: createAnyTimerSet())

        assertTimerSet(startSet, state: .stop, from: sut)
        
        sut.startCountdown() { _ in }
        assertTimerSet(startSet, state: .running, from: sut)
        
        sut.stopCountdown()
        assertTimerSet(startSet, state: .stop, from: sut)
    }
    
    func test_pause_twiceDoesNotChangeStateFromPause() {
        let startSet = createAnyTimerSet()
        let (sut, _) = makeSUT2(startingSet: startSet, nextSet: createAnyTimerSet())
        
        sut.pauseCountdown()
        sut.pauseCountdown()
        
        assertTimerSet(startSet, state: .pause, from: sut)
    }
    
    func test_pause_onRunningState_changesStateToPause() {
        let startSet = createAnyTimerSet()
        let (sut, _) = makeSUT2(startingSet: startSet, nextSet: createAnyTimerSet())
        sut.startCountdown() { _ in }
        
        sut.pauseCountdown()

        assertTimerSet(startSet, state: .pause, from: sut)
    }
    
    func test_pause_onRunningState_deliversCurrentState() {
        let startSet = createAnyTimerSet()
        let (sut, _) = makeSUT2(startingSet: startSet, nextSet: createAnyTimerSet())
        
        let receivedLocalTimerSets = receivedLocalTimerSetsOnRunningState(from: sut, when: {
            sut.pauseCountdown()
        })

        XCTAssertEqual(receivedLocalTimerSets, [startSet, startSet])
    }
    
    func test_skip_onStopState_deliversNextTimerSet() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let (sut, _) = makeSUT2(startingSet: startingSet, nextSet: nextSet)
        
        let receivedLocalTimerSets = receivedLocalTimerSetsOnSkip(from: sut)
        
        XCTAssertEqual(receivedLocalTimerSets, [nextSet])
    }
    
    func test_skip_onStopState_deliversCorrectSkipState() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let (sut, _) = makeSUT2(startingSet: startingSet, nextSet: nextSet)
        
        sut.skipCountdown { _ in }
        
        assertTimerSet(nextSet, state: .stop, from: sut)
    }
    
    func test_skip_onRunningState_deliversCorrectSkipState() {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        let (sut, _) = makeSUT2(startingSet: startingSet, nextSet: nextSet)
        sut.startCountdown { _ in }
        
        sut.skipCountdown { _ in }
        
        assertTimerSet(nextSet, state: .stop, from: sut)
    }
    
    func test_skip_onRunningState_deliversNextTimerSet() {
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
    private func starts(sut: TimerCountdown, spy: TimerNativeCommandsSpy,
                        incrementingValue: TimeInterval,
                        waitUntilPulseCount count: Int) {
        sut.startCountdown(completion: { _ in })
        (0..<count).forEach { _ in spy.completePulse(withIncrementingValue: incrementingValue) }
    }
    
    private func assertTimerSet(_ timerSet: TimerCountdownSet, state expectedState: TimerCountdownStateValues, from sut: TimerCountdown, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.currentState.state, expectedState, file: file, line: line)
        XCTAssertEqual(sut.currentSetElapsedTime, timerSet.elapsedSeconds, "should have expected \(timerSet.elapsedSeconds) but got \(sut.currentSetElapsedTime) current set.", file: file, line: line)
        XCTAssertEqual(sut.currentState.currentTimerSet, timerSet, file: file, line: line)
    }
    
    private func receivedLocalTimerSetsOnSkip(from sut: TimerCountdown) -> [TimerCountdownSet] {
        var receivedLocalTimerSets = [TimerCountdownSet]()
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
    
    private func receivedLocalTimerSetsOnRunningState(from sut: TimerCountdown, when action: () -> Void) -> [TimerCountdownSet] {
        var receivedLocalTimerSets = [TimerCountdownSet]()
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
    }
    
    private func assertsStartCountdownChangesStateToRunning(sut: TimerCountdown) {
        sut.startCountdown(completion: { _ in })

        XCTAssertEqual(sut.currentState.state, .running)
    }
    
    private func makeSUT(startingSet: TimerCountdownSet, nextSet: TimerCountdownSet,
                         incrementing: Double = 0.001,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> TimerCountdown {
        let sut = FactoryFoundationTimer.createTimer(startingSet: startingSet, nextSet: nextSet, incrementing: incrementing)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func makeSUT2(startingSet: TimerCountdownSet, nextSet: TimerCountdownSet,
                         incrementing: Double = 0.001,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: TimerCountdown, spy: TimerNativeCommandsSpy) {
        let spy = TimerNativeCommandsSpy()
        let sut = FactoryFoundationTimer
            .createTimer2(startingSet: startingSet, nextSet: nextSet, timer: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private class TimerNativeCommandsSpy: TimerNativeCommands {
        private var startCompletions = [TimerPulse]()
        func startTimer(completion: @escaping TimerPulse) {
            startCompletions.append(completion)
        }
        
        func invalidateTimer() {
        }
        
        func suspend() {
        }
        
        func resume() {
        }
        
        func completePulse(withIncrementingValue value: TimeInterval, at index: Int = 0) {
            startCompletions[index](value)
        }
    }
    
    private func starts(sut: TimerCountdown, 
                        expectingToDeliver deliverExpectation: [TimerCountdownSet],
                        incrementing: Int,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
    }
    
    private func starts(sut: TimerCountdown, expectingToDeliver deliverExpectation: [TimerCountdownSet],
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var receivedLocalTimerSets = [TimerCountdownSet]()
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
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date? = nil) -> TimerCountdownSet {
        makeAnyTimerSet(startDate: startDate, endDate: endDate ?? startDate.adding(seconds: 1)).local
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> TimerCountdownSet {
        makeAnyTimerSet(seconds: elapsedSeconds, startDate: startDate, endDate: endDate).local
    }
    
    private func invalidatesTimer(on sut: TimerCountdown) {
        (sut as? FoundationTimerCountdown)?.invalidateTimer()
    }
    
    private func makeAnyTimerSet(seconds: TimeInterval = 0,
                                 startDate: Date = Date(),
                                 endDate: Date = Date()) -> (model: TimerSet, local: TimerCountdownSet) {
        let timerSet = TimerSet(seconds, startDate: startDate, endDate: endDate)
        let localTimerSet = TimerCountdownSet(seconds, startDate: startDate, endDate: endDate)
        
        return (timerSet, localTimerSet)
    }
}

private extension TimerSet {
    var local: TimerCountdownSet {
        TimerCountdownSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}

