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
    
    // MARK: - Helpers
    private func makeSUT(
        pomodoroSecondsToBeFlushed: TimeInterval = 0.0,
        breakSecondsToBeFlushed: TimeInterval = 1.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (timerView: TimerView, spy: TimerCountdownSpy) {
        let spy = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 0.0...pomodoroSecondsToBeFlushed,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 0.0...breakSecondsToBeFlushed,
            breakStub: breakResponse)
        let spyTimerState = TimerStateSpy()
        
        let sut = TimeCoach_Watch_AppApp(timerCoundown: spy, timerState: spyTimerState).timerView
        
        trackForMemoryLeak(instance: spy, file: file, line: line)
        trackForMemoryLeak(instance: spyTimerState, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func timerViewOnPlayUserInteraction(afterSeconds seconds: TimeInterval,
                                                file: StaticString = #filePath,
                                                line: UInt = #line) -> TimerView {
        let (sut, stub) = makeSUT(pomodoroSecondsToBeFlushed: seconds, breakSecondsToBeFlushed: 1.0, file: file, line: line)
        
        sut.simulateToggleTimerUserInteraction()
        
        stub.flushPomodoroTimes(at: 0)
        
        return sut
    }
}
