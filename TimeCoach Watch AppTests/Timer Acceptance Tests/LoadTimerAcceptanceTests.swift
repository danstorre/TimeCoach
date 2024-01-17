import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class LoadTimerAcceptanceTests: XCTestCase {
    
    func test_OnForeground_shouldSendMessageToTimeLoader() {
        let (sut, spy) = makeSUT()

        sut.simulateGoToForeground()
        
        XCTAssertEqual(spy.loadTimerStateCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (timerView: TimeCoach_Watch_AppApp, spy: LocalTimerStoreSpy) {
        let spy = TimerCountdownSpy.delivers(
            afterPomoroSeconds: 0.0...0.0,
            pomodoroStub: pomodoroResponse,
            afterBreakSeconds: 0.0...0.0,
            breakStub: breakResponse)
        let spyTimeState = LocalTimerStoreSpy()
        
        let infra = Infrastructure(
            timerCountdown: spy,
            timerState: DummyTimerLoad(),
            stateTimerStore: spyTimeState,
            scheduler: DummyScheduler(),
            backgroundTimeExtender: BackgroundExtendedTimeNullObject()
        )
        
        let sut = TimeCoach_Watch_AppApp(infrastructure: infra)
        
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spyTimeState)
    }
}

fileprivate struct DummyTimerLoad: TimerLoad, TimerSave {
    func saveTime(completion: @escaping (TimeInterval) -> Void) {}
    
    func loadTime() {}
}
