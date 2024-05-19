import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class LoadTimerAcceptanceTests: XCTestCase {
    
    func test_onForegroundAndOnStopState_afterGoingToBackground_shouldNotSendLoadMessageToLocalTimer() {
        let current = Date.now
        let timeProvider = MockProviderDate(date: current)
        let (sut, spy, _) = makeSUT(getCurrentTime: timeProvider.getCurrentTime)
        
        sut.simulateGoToBackground()
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.loadTimerStateCallCount, 0)
    }
    
    func test_onForegroundAndOnPauseState_afterGoingToBackground_shouldNotSendMessagesToTimerLoader() {
        let (sut, foregroundSyncSpy, timerSpy) = makeSUT()
        
        sut.simulatePlayUserInteraction()
        timerSpy.changeStateToPlay()
        
        sut.simulatePauseUserInteraction()
        timerSpy.changeStateToPause()
        
        sut.simulateGoToBackground()
        sut.simulateGoToForeground()
        
        XCTAssertEqual(foregroundSyncSpy.loadTimerStateCallCount, 0)
    }
    
    func test_onForegroundAndOnPlayState_afterGoingToBackground_shouldSendMessageToTimeLoader() {
        let (sut, spy, timerSpy) = makeSUT()

        sut.simulatePlayUserInteraction()
        timerSpy.changeStateToPlay()
        sut.simulateGoToBackground()
        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.loadTimerStateCallCount, 1)
    }
    
    func test_onForegroundAndOnPlayState_afterGoingToBackground_shouldSetTimerCorrectly() {
        let current = Date.now
        let timeProvider = MockProviderDate(date: current)
        let (sut, spy, timerSpy) = makeSUT(getCurrentTime: timeProvider.getCurrentTime)
        let expectedStarEndDate = anyStartEndDate()
        let expectedElapsedSeconds = anyElapsedSeconds()
        
        let stubbedLocalTimerSet = createLocalTimerSet(
            elapsedSeconds: expectedElapsedSeconds,
            startDate: expectedStarEndDate.startDate,
            endDate: expectedStarEndDate.endDate
        )
        
        spy.stubbedInfrastructureLocalTimerState = createLocalTimerState(timerSet: stubbedLocalTimerSet)
        
        sut.simulatePlayUserInteraction()
        timerSpy.changeStateToPlay()
        sut.simulateGoToBackground()
        sut.simulateGoToForeground()
        
        XCTAssertEqual(
            spy.setableTimerMessagesReceived, [
                .setStarEndDate(startDate: expectedStarEndDate.startDate,
                                endDate: expectedStarEndDate.endDate),
                .set(elapsedSeconds: expectedElapsedSeconds)
            ]
        )
    }
    
    func test_onForegroundAndOnPlayState_AfterOneSecondOnBackground_shouldSetTimerCorrectly() {
        let current = Date.now
        let timeProvider = MockProviderDate(date: current)
        let (sut, spy, timerSpy) = makeSUT(getCurrentTime: timeProvider.getCurrentTime)
        let expectedElapsedSeconds: TimeInterval = 1
        let anyStarEndDate = anyStartEndDate(rangeInSecond: 2)
        let stubbedLocalTimerSet = createLocalTimerSet(
            elapsedSeconds: 0,
            startDate: anyStarEndDate.startDate,
            endDate: anyStarEndDate.endDate
        )
        spy.stubbedInfrastructureLocalTimerState = createLocalTimerState(timerSet: stubbedLocalTimerSet)
        
        sut.simulatePlayUserInteraction()
        timerSpy.changeStateToPlay()
        sut.simulateGoToBackground()
        timeProvider.passingSeconds(expectedElapsedSeconds)
        sut.simulateGoToForeground()
        
        XCTAssertEqual(
            spy.setableTimerMessagesReceived, [
                .setStarEndDate(startDate: anyStarEndDate.startDate,
                                endDate: anyStarEndDate.endDate),
                .set(elapsedSeconds: expectedElapsedSeconds)
            ]
        )
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
