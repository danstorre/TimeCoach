import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class SaveTimerAcceptanceTests: XCTestCase {

    func test_OnBackground_shouldSendMessageToTimeSaver() {
        let (sut, spy) = makeSUT()

        sut.simulateGoToBackground()
        
        XCTAssertEqual(spy.saveTimeCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (timerView: TimeCoach_Watch_AppApp, spy: TimerStateSpy) {
        let spy = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 0.0...0.0,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 0.0...0.0,
            breakStub: breakResponse)
        let spyTimeState = TimerStateSpy()
        
        let sut = TimeCoach_Watch_AppApp(pomodoroTimer: spy,
                                         timerState: spyTimeState)
        
        trackForMemoryLeak(instance: spy)
        
        return (sut, spyTimeState)
    }

}
