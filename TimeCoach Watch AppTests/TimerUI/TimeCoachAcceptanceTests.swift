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
        let (sut, stub) = makeSUT(pomodoroSecondsToBeFlushed: 1.0, breakSecondsToBeFlushed: 1.0)
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        stub.flushPomodoroTimes(at: 0)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        sut.simulateSkipTimerUserInteraction()
        
        stub.completeSuccessfullyOnSkip()
        
        XCTAssertEqual(sut.timerLabelString(), "05:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        stub.flushBreakTimes(at: 1)
        
        XCTAssertEqual(sut.timerLabelString(), "04:59")
    }
    
    func test_onLaunch_AfterPlayUserInteraction_OnStopUserInteraction_shouldShowCorrectTimer() {
        let (sut, stub) = makeSUT(pomodoroSecondsToBeFlushed: 1.0, breakSecondsToBeFlushed: 1.0)
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        stub.flushPomodoroTimes(at: 0)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        sut.simulateStopTimerUserInteraction()
        
        stub.completeSuccessfullyOnPomodoroStop()
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
    }
    
    func test_onLaunch_AfterPlayUserInteraction_OnPauseUserIntereaction_shouldShowCorrectTimer() {
        let (sut, stub) = makeSUT(pomodoroSecondsToBeFlushed: 1.0, breakSecondsToBeFlushed: 1.0)
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        stub.flushPomodoroTimes(at: 0)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        stub.completeSuccessfullyOnPomodoroToggle(at: 1)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
    }
    
    // MARK: - Helpers
    private func makeSUT(
        pomodoroSecondsToBeFlushed: TimeInterval = 0.0,
        breakSecondsToBeFlushed: TimeInterval = 1.0
    ) -> (timerView: TimerView, spy: TimerCountdownSpy) {
        let spy = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 0.0...pomodoroSecondsToBeFlushed,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 0.0...breakSecondsToBeFlushed,
            breakStub: breakResponse)
        let sut = TimeCoach_Watch_AppApp(timerCoundown: spy).timerView
        
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
