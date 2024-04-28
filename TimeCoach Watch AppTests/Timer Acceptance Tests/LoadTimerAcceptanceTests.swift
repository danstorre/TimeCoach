import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class LoadTimerAcceptanceTests: XCTestCase {
    
    func test_OnForeground_shouldSendMessageToTimeLoader() {
        let (sut, spy) = makeSUT()

        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.loadTimerStateCallCount, 1)
    }
    
    func test_onForeground_shouldSetTimerElapsedSecondsLoadedFromInfrastructure() {
        let current = Date.now
        let timeProvider = MockProviderDate(date: current)
        let (sut, spy) = makeSUT(getCurrentTime: timeProvider.getCurrentTime)
        let expectedElapsedSeconds = anyElapsedSeconds()
        let anyStarEndDate = anyStartEndDate()
        
        let stubbedLocalTimerSet = createLocalTimerSet(
            elapsedSeconds: expectedElapsedSeconds,
            startDate: anyStarEndDate.startDate,
            endDate: anyStarEndDate.endDate
        )
        
        spy.stubbedInfrastructureLocalTimerState = createLocalTimerState(timerSet: stubbedLocalTimerSet)
        
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.elapsedSecondsSet, [expectedElapsedSeconds], "expected to set \([expectedElapsedSeconds]) elapsed seconds, got \(spy.elapsedSecondsSet) elapsed seconds instead.")
    }
    
    func test_onForeground_afterOneSecondOnBackground_timerShouldSetTimeCorrectly() {
        let current = Date.now
        let timeProvider = MockProviderDate(date: current)
        let (sut, spy) = makeSUT(getCurrentTime: timeProvider.getCurrentTime)
        let anyStarEndDate = anyStartEndDate(rangeInSecond: 2)
        let stubbedLocalTimerSet = createLocalTimerSet(
            elapsedSeconds: 0,
            startDate: anyStarEndDate.startDate,
            endDate: anyStarEndDate.endDate
        )
        spy.stubbedInfrastructureLocalTimerState = createLocalTimerState(timerSet: stubbedLocalTimerSet)
        let expectedElapsedSeconds: TimeInterval = 1
        
        sut.simulatePlayUserInteraction()
        sut.simulateGoToBackground()
        timeProvider.passingSeconds(expectedElapsedSeconds)
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.elapsedSecondsSet, [expectedElapsedSeconds], "expected to receive an array of \([expectedElapsedSeconds]) elapsed seconds, got an array of \(spy.elapsedSecondsSet) elapsed seconds instead.")
    }
    
    func test_onForeground_shouldSetStartEndDateLoadedFromInfrastructure() {
        let (sut, spy) = makeSUT()
        let expectedStarEndDate = anyStartEndDate()
        
        let stubbedLocalTimerSet = createLocalTimerSet(
            elapsedSeconds: anyElapsedSeconds(),
            startDate: expectedStarEndDate.startDate,
            endDate: expectedStarEndDate.endDate
        )
        
        spy.stubbedInfrastructureLocalTimerState = createLocalTimerState(timerSet: stubbedLocalTimerSet)
        
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.startDatesSet, [expectedStarEndDate.startDate], "expected to set \([expectedStarEndDate.startDate]) start date, got \(spy.startDatesSet) start dates instead.")
        
        XCTAssertEqual(spy.endDatesSet, [expectedStarEndDate.endDate], "expected to set \([expectedStarEndDate.endDate]) end date, got \(spy.endDatesSet) end dates instead.")
    }
    
    func test_onForeground_shouldExecuteStartEndDateOperationFirst() {
        let (sut, spy) = makeSUT()
        spy.stubbedInfrastructureLocalTimerState = anyLocalTimerState()
        
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.messagesReceived, [
            .setStarEndDate,
            .setElapsedSeconds
        ])
    }
    
    // MARK: - Helpers
    private class MockProviderDate {
        private var date: Date
        
        init(date: Date) {
            self.date = date
        }
        
        func getCurrentTime() -> Date {
            date
        }
        
        func passingSeconds(_ seconds: TimeInterval) {
            date = date.adding(seconds: seconds)
        }
    }
    
    private func createLocalTimerSet(elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalTimerSet {
        return LocalTimerSet(
            elapsedSeconds,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    private func createLocalTimerState(timerSet: LocalTimerSet) -> LocalTimerState {
        LocalTimerState(
            localTimerSet: timerSet,
            state: anyState()
        )
    }
    
    private func anyLocalTimerState() -> LocalTimerState {
        LocalTimerState(localTimerSet: anyLocalTimerSet(),
                        state: .pause,
                        isBreak: false)
    }
    
    private func anyLocalTimerSet() -> LocalTimerSet {
        let anyStartEndDate = anyStartEndDate()
        return LocalTimerSet(anyElapsedSeconds(),
                             startDate: anyStartEndDate.startDate,
                             endDate: anyStartEndDate.endDate)
    }
    
    private func anyStartEndDate(rangeInSecond: TimeInterval = 1) -> (startDate: Date, endDate: Date) {
        let anyStarDate = Date.now
        let anyEndDate = anyStarDate.adding(seconds: rangeInSecond)
        return (anyStarDate, anyEndDate)
    }
    
    private func anyElapsedSeconds() -> TimeInterval {
        0
    }
    
    private func anyState() -> LocalTimerState.State {
        .pause
    }
    
    private func makeSUT(getCurrentTime currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (timerView: TimeCoach_Watch_AppApp, spy: ForegroundSyncSpy) {
        let spy = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 0.0...0.0,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 0.0...0.0,
            breakStub: breakResponse)
        let foregroundSyncSpy = ForegroundSyncSpy()
        
        let infra = Infrastructure(
            timerCountdown: spy,
            timerState: DummyTimerLoad(),
            stateTimerStore: foregroundSyncSpy,
            scheduler: DummyScheduler(),
            currentDate: currentDate,
            backgroundTimeExtender: BackgroundExtendedTimeNullObject(),
            setabletimer: foregroundSyncSpy
        )
        
        let sut = TimeCoach_Watch_AppApp(infrastructure: infra)
        
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, foregroundSyncSpy)
    }
}

fileprivate struct DummyTimerLoad: TimerLoad, TimerSave {
    func saveTime(completion: @escaping (TimeInterval) -> Void) {}
    
    func loadTime() {}
}
