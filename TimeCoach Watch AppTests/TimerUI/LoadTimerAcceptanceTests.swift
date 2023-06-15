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
        
        let sut = TimeCoach_Watch_AppApp(timerCoundown: spy,
                                         timerState: spyTimeState)
        
        trackForMemoryLeak(instance: spy)
        
        return (sut, spyTimeState)
    }
    
    class TimerStateSpy: TimerSave, TimerLoad {
        private(set) var saveTimeCallCount: Int = 0
        private(set) var loadTimeCallCount: Int = 0
        
        func saveTime(completion: @escaping (TimeInterval) -> Void) {
            saveTimeCallCount += 1
        }
        
        func loadTime() {
            loadTimeCallCount += 1
        }
    }
    
}

