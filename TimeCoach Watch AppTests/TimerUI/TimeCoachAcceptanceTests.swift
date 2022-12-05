import XCTest
import LifeCoach
import LifeCoachWatchOS
import Combine
@testable import TimeCoach_Watch_App

final class TimeCoachAcceptanceTests: XCTestCase {
    func test_onLaunch_shouldDisplayPomodoroTimer() {
        let (sut, _) = makeSUT(pomodoroSecondsToBeFlushed: 0.0)
        
        let timerLabelString = sut.timerLabelString()
        
        XCTAssertEqual(timerLabelString, "25:00")
    }
    
    func test_onLaunch_shouldDisplayCorrectCustomFont() {
        let (sut, _) = makeSUT(pomodoroSecondsToBeFlushed: 0.0)
        
        let customFont = sut.customFont
        
        XCTAssertEqual(customFont, .timerFont)
    }
    
    func test_onLaunch_OnGivenSeconds_shouldShowCorrectTimerOnPlayUserInteraction() {
        let timer1 = timerViewOnPlayUserInteraction(afterSeconds: 1.0)
        
        XCTAssertEqual(timer1.timerLabelString(), "24:59")
        
        let timer2 = timerViewOnPlayUserInteraction(afterSeconds: 2.0)
        
        XCTAssertEqual(timer2.timerLabelString(), "24:58")
        
        let timer3 = timerViewOnPlayUserInteraction(afterSeconds: 5.0)
        
        XCTAssertEqual(timer3.timerLabelString(), "24:55")
    }
    
    func test_onLaunch_OnSkipUserInteraction_shouldShowCorrectTimerOnPlayUserInteraction() {
        let (sut, spy) = makeSUT(pomodoroSecondsToBeFlushed: 1.0, breakSecondsToBeFlushed: 1.0)
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        spy.flushPomodoroTimes(at: 0)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        sut.simulateSkipTimerUserInteraction()
        
        spy.completeSuccessfullyOnSkip()
        
        XCTAssertEqual(sut.timerLabelString(), "05:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        spy.flushBreakTimes(at: 1)
        
        XCTAssertEqual(sut.timerLabelString(), "04:59")
    }
    
    func test_onLaunch_AfterPlayUserInteraction_OnStopUserInteraction_shouldShowCorrectTimer() {
        let (sut, spy) = makeSUT(pomodoroSecondsToBeFlushed: 1.0, breakSecondsToBeFlushed: 1.0)
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        spy.flushPomodoroTimes(at: 0)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        sut.simulateStopTimerUserInteraction()
        
        spy.completeSuccessfullyOnPomodoroStop()
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
    }
    
    func test_onLaunch_AfterPlayUserInteraction_OnPauseUserIntereaction_shouldShowCorrectTimer() {
        let (sut, spy) = makeSUT(pomodoroSecondsToBeFlushed: 1.0, breakSecondsToBeFlushed: 1.0)
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        spy.flushPomodoroTimes(at: 0)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        spy.completeSuccessfullyOnPomodoroToggle(at: 1)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
    }
    
    func test_OnBackground_shouldSendMessageToTimeSaver() {
        let (sut, spy) = makeSUT()

        sut.simulateGoToBackground()
        
        XCTAssertEqual(spy.saveTimeCallCount, 1)
    }
    
    func test_OnForeground_shouldSendMessageToTimeLoader() {
        let (sut, spy) = makeSUT()

        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.loadTimeCallCount, 1)
    }

    // MARK: - Helpers
    class TimerStateSpy: TimerSave, TimerLoad {
        private(set) var saveTimeCallCount: Int = 0
        private(set) var loadTimeCallCount: Int = 0
        
        func saveTime() {
            saveTimeCallCount += 1
        }
        
        func loadTime() {
            loadTimeCallCount += 1
        }
    }
    
    private func makeSUT() -> (timerView: TimeCoach_Watch_AppApp, spy: TimerStateSpy) {
        let spy = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 0.0...0.0,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 0.0...0.0,
            breakStub: breakResponse)
        let spyTimeState = TimerStateSpy()
        
        let sut = TimeCoach_Watch_AppApp(timerCoundown: spy,
                                         timerState: spyTimeState)
        
        trackForMemoryLeak(instance: spy)
        
        return (sut, spyTimeState)
    }
    
    private func makeSUT(
        pomodoroSecondsToBeFlushed: TimeInterval = 0.0,
        breakSecondsToBeFlushed: TimeInterval = 1.0
    ) -> (timerView: TimerView, spy: TimerCountdownSpy) {
        let spy = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 0.0...pomodoroSecondsToBeFlushed,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 0.0...breakSecondsToBeFlushed,
            breakStub: breakResponse)
        let spyState = TimerStateSpy()
        
        let sut = TimeCoach_Watch_AppApp(timerCoundown: spy, timerState: spyState).timerView
        
        trackForMemoryLeak(instance: spy)
        
        return (sut, spy)
    }
    
    private func timerViewOnPlayUserInteraction(afterSeconds seconds: TimeInterval) -> TimerView {
        let (sut, stub) = makeSUT(pomodoroSecondsToBeFlushed: seconds, breakSecondsToBeFlushed: 1.0)
        
        sut.simulateToggleTimerUserInteraction()
        
        stub.flushPomodoroTimes(at: 0)
        
        return sut
    }
}

extension String {
    static var timerFont: String {
        CustomFont.timer.font
    }
}

extension TimeCoach_Watch_AppApp {
    func simulateGoToBackground() {
        goToBackground()
    }
    
    func simulateGoToForeground() {
        goToForeground()
    }
}
