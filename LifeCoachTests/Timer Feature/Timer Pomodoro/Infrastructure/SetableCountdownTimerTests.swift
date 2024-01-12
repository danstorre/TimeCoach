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
        XCTAssertEqual(sut.currentSetElapsedTime, timerSet.elapsedSeconds, "expected \(timerSet.elapsedSeconds) but got \(sut.currentSetElapsedTime) for the current set.", file: file, line: line)
        XCTAssertEqual(sut.currentState.currentTimerSet, timerSet, file: file, line: line)
    }
}

extension TimerCountdownSet {
    func adding(_ seconds: Double) -> TimerCountdownSet {
        TimerCountdownSet(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}
