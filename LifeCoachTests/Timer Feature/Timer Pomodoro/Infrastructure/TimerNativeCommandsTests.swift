import LifeCoach
import XCTest

class TimerNativeCommandsTests: XCTestCase {
    func test_resume_onStartedTimer_DoesNotCrash() {
        let sut = makeSUT()
        
        sut.startTimer { _ in }
        sut.resume()
    }
    
    func test_resume_onStopTimer_twice_DoesNotCrash() {
        let sut = makeSUT()
        
        sut.resume()
        sut.resume()
    }
    
    func test_resume_afterInvalidTimer_DoesNotCrash() {
        let sut = makeSUT()
        
        sut.invalidateTimer()
        sut.resume()
    }
    
    func test_resume_afterSuspended_DoesNotCrash() {
        let sut = makeSUT()
        
        sut.startTimer { _ in }
        sut.suspend()
        sut.resume()
    }
    
    func test_supendsCurrentTimer_twice_doesNotCrash() {
        let sut = makeSUT()
        
        sut.suspend()
        sut.suspend()
    }
    
    func test_suspendTimer_onRunningTimer_DoesNotCrash() {
        let sut = makeSUT()
        
        sut.startTimer { _ in }
        sut.suspend()
    }
    
    func test_invalidateTimer_onSuspendedTimer_DoesNotCrash() {
        let sut = makeSUT()
        
        sut.startTimer { _ in }
        sut.suspend()
        
        sut.invalidateTimer()
    }
    
    func test_startTimer_onPulseCompletion_deliversIncrementingValue() {
        let incrementing = 0.1
        let sut = makeSUT(incrementing: incrementing)
        
        let receivedIncrementingValues = getReceivedIncrementingValues(from: sut, onPulseCount: 1)
        
        let expectedIncrementingValues = [incrementing]
        XCTAssertEqual(receivedIncrementingValues, expectedIncrementingValues)
    }
    
    // MARK: - Helpers
    private func getReceivedIncrementingValues(from sut: TimerNativeCommands,
                                               onPulseCount pulseCount: Int) -> [TimeInterval] {
        let expectation = expectation(description: "wait for timer pulses.")
        expectation.expectedFulfillmentCount = pulseCount
        
        var receivedIncrementingValues = [TimeInterval]()
        sut.startTimer { incrementingValue in
            receivedIncrementingValues.append(incrementingValue)
            expectation.fulfill()
        }
        
        wait(for: [expectation])
        
        return receivedIncrementingValues
    }
    
    private func makeSUT(incrementing: TimeInterval = 0.001,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> TimerNativeCommands {
        let sut = TimerNative(incrementing: incrementing)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date? = nil) -> TimerCountdownSet {
        makeAnyTimerSet(startDate: startDate, endDate: endDate ?? startDate.adding(seconds: 1)).local
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> TimerCountdownSet {
        makeAnyTimerSet(seconds: elapsedSeconds, startDate: startDate, endDate: endDate).local
    }
    
    private func makeAnyTimerSet(seconds: TimeInterval = 0,
                                 startDate: Date = Date(),
                                 endDate: Date = Date()) -> (model: TimerSet, local: TimerCountdownSet) {
        let timerSet = TimerSet(seconds, startDate: startDate, endDate: endDate)
        let localTimerSet = TimerCountdownSet(seconds, startDate: startDate, endDate: endDate)
        
        return (timerSet, localTimerSet)
    }
}
