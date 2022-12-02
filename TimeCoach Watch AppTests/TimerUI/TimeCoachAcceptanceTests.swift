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
    
    // MARK: - Helpers
    private func timerViewOnPlayUserInteraction(afterSeconds seconds: TimeInterval) -> TimerView {
        let stub = TimerCountdownSpy.delivers(after: 1.0...seconds, pomodoroResponse)
        let sut = TimeCoach_Watch_AppApp(timerCoundown: stub).timerView
        
        sut.simulateToggleTimerUserInteraction()
        
        stub.completeSuccessfullyAfterFirstStart()
        
        return sut
    }
}

extension String {
    static var timerFont: String {
        CustomFont.timer.font
    }
}
