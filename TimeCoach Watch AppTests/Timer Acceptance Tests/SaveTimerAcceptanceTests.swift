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
        
        let infra = Infrastructure(
            timerCountdown: spy,
            timerState: spyTimeState,
            stateTimerStore: DummyLocalTimerStore(),
            scheduler: DummyScheduler()
        )
        
        let sut = TimeCoach_Watch_AppApp(infrastructure: infra)
        
        trackForMemoryLeak(instance: spy)
        
        return (sut, spyTimeState)
    }

}
