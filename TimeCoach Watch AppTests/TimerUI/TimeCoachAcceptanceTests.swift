import XCTest
import LifeCoach
import LifeCoachWatchOS
import Combine
@testable import TimeCoach_Watch_App

final class TimeCoachAcceptanceTests: XCTestCase {
    func test_onLaunch_shouldDisplayPomodoroTimer() {
        let sut = TimeCoach_Watch_AppApp().timerView
        
        let timerLabelString = sut.timerLabelString()
        
        XCTAssertEqual(timerLabelString, "25:00")
    }
    
    func test_onLaunch_shouldDisplayCorrectCustomFont() {
        let sut = TimeCoach_Watch_AppApp().timerView
        
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
        let stub = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 1.0...1.0,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 1.0...1.0,
            breakStub: breakResponse)
        let sut = TimeCoach_Watch_AppApp(timerCoundown: stub).timerView
        
        XCTAssertEqual(sut.timerLabelString(), "25:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        stub.flushPomodoroTimes(at: 0)
        
        XCTAssertEqual(sut.timerLabelString(), "24:59")
        
        sut.simulateSkipTimerUserInteraction()
        
        stub.completeSuccessfullyOnSkip()
        
        XCTAssertEqual(sut.timerLabelString(), "05:00")
        
        sut.simulateToggleTimerUserInteraction()
        
        stub.flushBreakTimes(at: 2)
        
        XCTAssertEqual(sut.timerLabelString(), "04:59")
    }
    
    // MARK: - Helpers
    private func timerViewOnPlayUserInteraction(afterSeconds seconds: TimeInterval) -> TimerView {
        let stub = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 1.0...seconds,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 1.0...1.0,
            breakStub: breakResponse)
        let sut = TimeCoach_Watch_AppApp(timerCoundown: stub).timerView
        
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
