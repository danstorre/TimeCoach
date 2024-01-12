import XCTest
import LifeCoach

final class SetableCountdownTimerTests: XCTestCase {

    func test_setElapsedSeconds_setsTimersElapsecondsCorrectly() {
        let sampleInput = 1.0
        let startSet = createAnyTimerSet()
        let sut = makeSUT(startingSet: startSet, nextSet: createAnyTimerSet())
        
        sut.setElapsedSeconds(sampleInput)
        
        assertTimerSet(startSet.adding(sampleInput), state: .stop, from: sut)
    }
    
    // MARK: - helpers
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
        XCTAssertEqual(sut.currentSetElapsedTime, timerSet.elapsedSeconds, "should have expected \(timerSet.elapsedSeconds) but got \(sut.currentSetElapsedTime) current set.", file: file, line: line)
        XCTAssertEqual(sut.currentState.currentTimerSet, timerSet, file: file, line: line)
    }
}
