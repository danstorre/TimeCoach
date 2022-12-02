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
    
    func test_onLaunch_shouldShowCorrectTimerOneSecondAfterUserHitsPlay() {
        let timer = showTimerOneSecondAfterUserHitsPlay()
        
        XCTAssertEqual(timer.timerLabelString(), "24:59")
    }
    
    func test_onLaunch_shouldShowCorrectTimerTwoSecondsAfterUserHitsPlay() {
        let timer = showTimerTwoSecondAfterUserHitsPlay()
        
        XCTAssertEqual(timer.timerLabelString(), "24:58")
    }
    
    // MARK: - Helpers
    private func showTimerTwoSecondAfterUserHitsPlay() -> TimerView {
        let stub = TimerCountdownSpy.delivers(after: 1.0...2.0, pomodoroResponse)
        let sut = TimeCoach_Watch_AppApp(timerCoundown: stub).timerView
        
        sut.simulateToggleTimerUserInteraction()
        
        stub.completeSuccessfullyAfterFirstStart()
        
        return sut
    }
    
    private func showTimerOneSecondAfterUserHitsPlay() -> TimerView {
        let spy = TimerCountdownSpy.delivers(after: 1.0...1.0, pomodoroResponse)
        let sut = TimeCoach_Watch_AppApp(timerCoundown: spy).timerView
        
        sut.simulateToggleTimerUserInteraction()
        
        spy.completeSuccessfullyAfterFirstStart()
        
        return sut
    }
}

extension String {
    static var timerFont: String {
        CustomFont.timer.font
    }
}
