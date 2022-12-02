import XCTest
import LifeCoach
import LifeCoachWatchOS
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
    
    // MARK: - Helpers
    private func showTimerOneSecondAfterUserHitsPlay() -> TimerView {
        let stub = TimerCountdownStub.delivers(after: 1, pomodoroResponse)
        let sut = TimeCoach_Watch_AppApp(timerCoundown: stub).timerView
        
        sut.simulateToggleTimerUserInteraction()
        
        return sut
    }
    
    private func pomodoroResponse(_ seconds: TimeInterval) -> LocalElapsedSeconds {
        let start = Date.now
        return LocalElapsedSeconds(seconds, startDate: start, endDate: start.adding(seconds: .pomodoroInSeconds))
    }
    
    private class TimerCountdownStub: TimerCountdown {
        private let stub: () -> LocalElapsedSeconds
        
        init(stub: @escaping () -> LocalElapsedSeconds) {
            self.stub = stub
        }
        
        func pauseCountdown(completion: @escaping TimerCompletion) {
            
        }
        
        func skipCountdown(completion: @escaping TimerCompletion) {
            
        }
    
        func startCountdown(completion: @escaping TimerCompletion) {
            completion(stub())
        }
        
        func stopCountdown(completion: @escaping TimerCompletion) {
            
        }
        
        static func delivers(after seconds: TimeInterval,
                             _ stub: @escaping (TimeInterval) -> LocalElapsedSeconds) -> TimerCountdownStub {
            TimerCountdownStub {
                return stub(seconds)
            }
        }
    }
}

extension String {
    static var timerFont: String {
        CustomFont.timer.font
    }
}
