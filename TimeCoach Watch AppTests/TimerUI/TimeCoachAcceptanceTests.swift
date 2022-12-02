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
    
    func test_send_shouldNotSendAnyValuesOnSubscription() {
        let publisher = TimerCountdownSpy.delivers(after: 1.0...2.0, pomodoroResponse).getPublisher()
        
        var receivedValueCount = 0
        _ = publisher.sink { _ in
            
        } receiveValue: { _ in
            receivedValueCount += 1
        }
        
        XCTAssertEqual(receivedValueCount, 0)
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
    
    private func pomodoroResponse(_ seconds: TimeInterval) -> LocalElapsedSeconds {
        let start = Date.now
        return LocalElapsedSeconds(seconds, startDate: start, endDate: start.adding(seconds: .pomodoroInSeconds))
    }
    
    private class TimerCountdownSpy: TimerCountdown {
        private var stubs: [() -> LocalElapsedSeconds] = []
        private(set) var receivedStartCompletions = [TimerCompletion]()
        
        init(stubs: [() -> LocalElapsedSeconds]) {
            self.stubs = stubs
        }
        
        func pauseCountdown(completion: @escaping TimerCompletion) {
            
        }
        
        func skipCountdown(completion: @escaping TimerCompletion) {
            
        }
    
        func startCountdown(completion: @escaping TimerCompletion) {
            receivedStartCompletions.append(completion)
        }
        
        func stopCountdown(completion: @escaping TimerCompletion) {
            
        }
        
        func completeSuccessfullyAfterFirstStart() {
            stubs.forEach { stub in
                receivedStartCompletions[0](stub())
            }
        }
        
        static func delivers(after seconds: ClosedRange<TimeInterval>,
                             _ stub: @escaping (TimeInterval) -> LocalElapsedSeconds) -> TimerCountdownSpy {
            let start: Int = Int(seconds.lowerBound)
            let end: Int = Int(seconds.upperBound)
            let array: [TimeInterval] = (start...end).map { TimeInterval($0) }
            let stubs = array.map { seconds in
                {
                    return stub(seconds)
                }
            }
            return TimerCountdownSpy(stubs: stubs)
        }
    }
}

extension String {
    static var timerFont: String {
        CustomFont.timer.font
    }
}
