import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class LoadTimerAcceptanceTests: XCTestCase {
    
    func test_OnForeground_shouldSendMessageToTimeLoader() {
        let (sut, spy) = makeSUT()

        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.loadTimeCallCount, 1)
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
                                         timerState: spyTimeState,
                                         stateTimerStore: DummyLocalTimerStore(),
                                         scheduler: DummyScheduler())
        
        trackForMemoryLeak(instance: spy)
        
        return (sut, spyTimeState)
    }
    
}

