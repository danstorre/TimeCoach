import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class LoadTimerAcceptanceTests: XCTestCase {
    
    func test_onForeground_onStopTimerState_shouldNotSendLoadMessageToLocalTimer() {
        let current = Date.now
        let timeProvider = MockProviderDate(date: current)
        let (sut, spy, _) = makeSUT(getCurrentTime: timeProvider.getCurrentTime)
        
        sut.simulateGoToBackground()
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.retrieveLocalTimerStateCallCount, 0)
    }
    
    func test_OnForeground_afterPlayUserInteraction_shouldSendMessageToTimeLoader() {
        let (sut, spy, stub) = makeSUT()

        sut.simulatePlayUserInteraction()
        stub.flushPomodoroTimes(at: 0)
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.retrieveLocalTimerStateCallCount, 1)
    }
    
    func test_onForeground_afterPlayUserInteraction_shouldSetTimerElapsedSecondsLoadedFromInfrastructure() {
        let current = Date.now
        let timeProvider = MockProviderDate(date: current)
        let (sut, spy, stub) = makeSUT(getCurrentTime: timeProvider.getCurrentTime)
        let expectedElapsedSeconds = anyElapsedSeconds()
        let anyStarEndDate = anyStartEndDate()
        
        let stubbedLocalTimerSet = createLocalTimerSet(
            elapsedSeconds: expectedElapsedSeconds,
            startDate: anyStarEndDate.startDate,
            endDate: anyStarEndDate.endDate
        )
        
        spy.stubbedInfrastructureLocalTimerState = createLocalTimerState(timerSet: stubbedLocalTimerSet)
        
        sut.simulatePlayUserInteraction()
        stub.flushPomodoroTimes(at: 0)
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.elapsedSecondsSet, [expectedElapsedSeconds], "expected to set \([expectedElapsedSeconds]) elapsed seconds, got \(spy.elapsedSecondsSet) elapsed seconds instead.")
    }
    
    func test_onForeground_afterPlayUserInteractionAndOneSecondOnBackground_timerShouldSetTimeCorrectly() {
        let current = Date.now
        let timeProvider = MockProviderDate(date: current)
        let (sut, spy, stub) = makeSUT(getCurrentTime: timeProvider.getCurrentTime)
        let expectedElapsedSeconds: TimeInterval = 1
        let anyStarEndDate = anyStartEndDate(rangeInSecond: 2)
        let stubbedLocalTimerSet = createLocalTimerSet(
            elapsedSeconds: 0,
            startDate: anyStarEndDate.startDate,
            endDate: anyStarEndDate.endDate
        )
        spy.stubbedInfrastructureLocalTimerState = createLocalTimerState(timerSet: stubbedLocalTimerSet)
        
        sut.simulatePlayUserInteraction()
        stub.flushPomodoroTimes(at: 0)
        sut.simulateGoToBackground()
        timeProvider.passingSeconds(expectedElapsedSeconds)
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.elapsedSecondsSet, [expectedElapsedSeconds], "expected to receive an array of \([expectedElapsedSeconds]) elapsed seconds, got an array of \(spy.elapsedSecondsSet) elapsed seconds instead.")
    }
    
    func test_onForeground_afterPlayUserInteraction_shouldSetStartEndDateLoadedFromInfrastructure() {
        let (sut, spy, stub) = makeSUT()
        let expectedStarEndDate = anyStartEndDate()
        
        let stubbedLocalTimerSet = createLocalTimerSet(
            elapsedSeconds: anyElapsedSeconds(),
            startDate: expectedStarEndDate.startDate,
            endDate: expectedStarEndDate.endDate
        )
        
        spy.stubbedInfrastructureLocalTimerState = createLocalTimerState(timerSet: stubbedLocalTimerSet)
        
        sut.simulatePlayUserInteraction()
        stub.flushPomodoroTimes(at: 0)
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.startDatesSet, [expectedStarEndDate.startDate], "expected to set \([expectedStarEndDate.startDate]) start date, got \(spy.startDatesSet) start dates instead.")
        
        XCTAssertEqual(spy.endDatesSet, [expectedStarEndDate.endDate], "expected to set \([expectedStarEndDate.endDate]) end date, got \(spy.endDatesSet) end dates instead.")
    }
    
    func test_onForeground_afterPlayUserInteraction_shouldExecuteStartEndDateOperationFirst() {
        let (sut, spy, stub) = makeSUT()
        spy.stubbedInfrastructureLocalTimerState = anyLocalTimerState()
        
        sut.simulatePlayUserInteraction()
        stub.flushPomodoroTimes(at: 0)
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
    
    private func makeSUT(getCurrentTime currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (timerView: TimeCoach_Watch_AppApp, spy: ForegroundSyncSpy, stubbedTimer: TimerCountdownSpy) {
        let stubbedTimer = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 0.0...0.0,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 0.0...0.0,
            breakStub: breakResponse)
        let foregroundSyncSpy = ForegroundSyncSpy()
        
        let infra = Infrastructure(
            timerCountdown: stubbedTimer,
            stateTimerStore: foregroundSyncSpy,
            scheduler: DummyScheduler(),
            currentDate: currentDate,
            backgroundTimeExtender: BackgroundExtendedTimeNullObject(),
            setabletimer: foregroundSyncSpy
        )
        
        let sut = TimeCoach_Watch_AppApp(infrastructure: infra)
        
        trackForMemoryLeak(instance: stubbedTimer, file: file, line: line)
        
        return (sut, foregroundSyncSpy, stubbedTimer)
    }
}
