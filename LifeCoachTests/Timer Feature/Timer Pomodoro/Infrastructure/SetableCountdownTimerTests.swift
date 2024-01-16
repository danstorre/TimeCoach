import XCTest
import LifeCoach

final class SetableCountdownTimerTests: XCTestCase {

    func test_setElapsedSeconds_setsTimersElapsecondsCorrectly() {
        let startSet = createAnyTimerSet()
        
        let samples: [(inputSeconds: Double, startSet: TimerCountdownSet, expected: TimerCountdownSet)] = [
            (inputSeconds: 0.0, startSet: startSet, expected: startSet),
            (inputSeconds: 1.0, startSet: startSet, expected: startSet.adding(1)),
            (inputSeconds: 60, startSet: startSet, expected: startSet.adding(60)),
            (inputSeconds: 0.0, startSet: startSet.adding(1), expected: startSet)
        ]
        
        samples.forEach { sample in
            let sut = makeSUT(startingSet: sample.startSet, nextSet: createAnyTimerSet())
            
            sut.setElapsedSeconds(sample.inputSeconds)
            
            assertTimerSet(sample.expected, state: .stop, from: sut)
        }
    }
    
    func test_setCustomStartEndDate_onSameStartEndDates_deliversSameDatesError() throws {
        let now = Date.now
        let sameSetDates = createAnyTimerSet(
            startingFrom: now, endDate: now
        )
        let startSet = createAnyTimerSet(
            startingFrom: now, endDate: now.adding(seconds: 1)
        )
        
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        let capturedError = failureOnCustomDatesSet(startDate: sameSetDates.startDate,
                                                    endDate: sameSetDates.endDate, sut: sut)
        
        failsWithSameDatesError(capturedError: capturedError)
    }
    
    func test_setCustomStartEndDate_onEndDateOlderThanStartDate_deliversOlderEndDateThanStartDateError() throws {
        let now = Date.now
        let olderEndDateThanStartDateSet = createAnyTimerSet(startingFrom: now, endDate: now.adding(seconds: -1))
        let startSet = createAnyTimerSet(startingFrom: now, endDate: now.adding(seconds: 1))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        let capturedError = failureOnCustomDatesSet(startDate: olderEndDateThanStartDateSet.startDate,
                                                    endDate: olderEndDateThanStartDateSet.endDate, sut: sut)
        
        failsWithOlderEndDateThanStartDateError(capturedError: capturedError)
    }
    
    func test_setCustomStartEndDate_setsStartAndDateFromCurrentSetCorrectly() throws {
        let now = Date.now
        let inputSet = createAnyTimerSet(startingFrom: now, endDate: now.adding(seconds: 1))
        let startSet = createAnyTimerSet(startingFrom: now, endDate: now.adding(seconds: 1))
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        try sut.set(startDate: inputSet.startDate, endDate: inputSet.endDate)
        
        assertTimerSet(inputSet, state: .stop, from: sut)
    }
    
    func test_setPauseTimerCountdownState_onStopState_setsPauseStateCorrectly() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        assertSetsPauseCorrectly(sut: sut, on: {
            sut.stopCountdown()
        })
    }
    
    func test_setStopTimerCountdownState_onStopState_setsStopStateCorrectly() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        assertSetsStopCorrectly(sut: sut, on: {
            sut.pauseCountdown()
        })
    }
    
    func test_setPauseTimerCountdownState_onPauseState_setsPauseStateCorrectly() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        assertSetsPauseCorrectly(sut: sut, on: {
            sut.pauseCountdown()
        })
    }
    
    func test_setStopTimerCountdownState_onPauseState_setsStopStateCorrectly() {
        let sut = makeSUT(startingSet: createAnyTimerSet(), nextSet: createAnyTimerSet())
        
        assertSetsStopCorrectly(sut: sut, on: {
            sut.pauseCountdown()
        })
    }
    
    // MARK: - helpers
    private func assertSetsStopCorrectly(
        sut: FoundationTimerCountdown,
        on action: (() -> Void),
        file: StaticString = #filePath, line: UInt = #line) {
        action()
            
        sut.set(state: .stop)
        
        XCTAssertEqual(sut.timerIsStopped, true, "timer should be stopped", file: file, line: line)
    }
    
    private func assertSetsPauseCorrectly(
        sut: FoundationTimerCountdown,
        on action: (() -> Void),
        file: StaticString = #filePath, line: UInt = #line) {
        action()
        
        sut.set(state: .pause)
        
        XCTAssertEqual(sut.timerIsPaused, true, "timer should be paused", file: file, line: line)
    }

    private func failsWithSameDatesError(capturedError: Error) {
        XCTAssertEqual(capturedError as? TimerCountdownSetValueError, TimerCountdownSetValueError.sameDatesNonPermitted)
    }
    
    private func failsWithOlderEndDateThanStartDateError(capturedError: Error) {
        XCTAssertEqual(capturedError as? TimerCountdownSetValueError, TimerCountdownSetValueError.endDateIsOlderThanStartDate)
    }
    
    private func failureOnCustomDatesSet(startDate: Date, endDate: Date, sut: FoundationTimerCountdown) -> TimerCountdownSetValueError {
        var capturedError: Error? = nil
        XCTAssertThrowsError(try sut.set(startDate: startDate, endDate: endDate)) { error in
            capturedError = error
        }
        
        return capturedError as! TimerCountdownSetValueError
    }
 
    private func makeSUT(startingSet: TimerCountdownSet, nextSet: TimerCountdownSet,
                         incrementing: Double = 0.001,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> FoundationTimerCountdown {
        let sut = FoundationTimerCountdown(startingSet: startingSet, nextSet: nextSet, incrementing: incrementing)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date = Date()) -> TimerCountdownSet {
        return TimerCountdownSet(0, startDate: startDate, endDate: endDate)
    }
    
    private func assertTimerSet(_ timerSet: TimerCountdownSet, state expectedState: TimerCountdownStateValues, from sut: TimerCountdown, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.currentState.state, expectedState, file: file, line: line)
        XCTAssertEqual(sut.currentSetElapsedTime, timerSet.elapsedSeconds, "expected elapsedSeconds \(timerSet.elapsedSeconds) but got \(sut.currentSetElapsedTime).", file: file, line: line)
        XCTAssertEqual(sut.currentState.currentTimerSet.startDate, timerSet.startDate, "expected startDate \(timerSet.startDate) but got \(sut.currentState.currentTimerSet.startDate) instead", file: file, line: line)
        XCTAssertEqual(sut.currentState.currentTimerSet.endDate, timerSet.endDate, "expected endDate \(timerSet.endDate) but got \(sut.currentState.currentTimerSet.endDate) instead", file: file, line: line)
    }
    
    private func invalidatesTimer(on sut: FoundationTimerCountdown) {
        sut.invalidatesTimer()
    }
}

extension TimerCountdownSet {
    func adding(_ seconds: Double) -> TimerCountdownSet {
        TimerCountdownSet(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}


fileprivate extension FoundationTimerCountdown {
    var timerIsPaused: Bool {
        currentState.state == .pause
    }
    
    var timerIsStopped: Bool {
        currentState.state == .stop
    }
}
