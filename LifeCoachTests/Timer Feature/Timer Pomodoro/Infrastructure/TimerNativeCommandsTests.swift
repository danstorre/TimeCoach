import LifeCoach
import XCTest

class TimerNativeCommandsTests: XCTestCase {
    func test_resume_onStartedTimer_DoesNotCrash() {
        let (startingSet, nextSet) = createDefaultTimerSets()
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        sut.startTimer {}
        sut.resume()
    }
    
    func test_resume_onStopTimer_twice_DoesNotCrash() {
        let (startingSet, nextSet) = createDefaultTimerSets()
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        sut.resume()
        sut.resume()
    }
    
    func test_resume_afterInvalidTimer_DoesNotCrash() {
        let (startingSet, nextSet) = createDefaultTimerSets()
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        sut.invalidateTimer()
        sut.resume()
    }
    
    func test_suspendTimer_onRunningTimer_DoesNotCrash() {
        let (startingSet, nextSet) = createDefaultTimerSets()
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        sut.startTimer {}
        sut.suspend()
    }
    
    func test_invalidateTimer_onSuspendedTimer_DoesNotCrash() {
        let (startingSet, nextSet) = createDefaultTimerSets()
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        sut.startTimer {}
        sut.suspend()
        
        sut.invalidateTimer()
    }
    
    func test_invalidateTimer_DoesNotCrash() {
        let (startingSet, nextSet) = createDefaultTimerSets()
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        sut.startTimer {}
        sut.suspend()
        sut.resume()
        
        sut.invalidateTimer()
    }
    
    func test_supendsCurrentTimer_twice_doesNotCrash() {
        let (startingSet, nextSet) = createDefaultTimerSets()
        let sut = makeSUT(startingSet: startingSet, nextSet: nextSet)
        
        sut.suspend()
        sut.suspend()
    }
    
    // MARK: - Helpers
    private func createDefaultTimerSets() -> (startingSet: TimerCountdownSet,
                                              nextSet: TimerCountdownSet) {
        let fixedDate = Date()
        let startingSet = createAnyTimerSet()
        let nextSet = createTimerSet(0, startDate: fixedDate, endDate: fixedDate.adding(seconds: 0.002))
        return (startingSet, nextSet)
    }
    
    private func makeSUT(startingSet: TimerCountdownSet, 
                         nextSet: TimerCountdownSet,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> TimerNativeCommands {
        let sut = FoundationTimerCountdown(startingSet: startingSet,
                                           nextSet: nextSet,
                                           incrementing: 0.1)
        
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
