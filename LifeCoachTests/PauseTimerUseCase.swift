import LifeCoach
import XCTest

final class PauseTimerUseCase: XCTestCase {
    func test_init_doesNotSendAnyMessageToTimer() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.pauseCountCallCount, 0)
    }
    
    func test_pauseTimer_sendsMessageToTimer() {
        let (sut, spy) = makeSUT()
        sut.pauseTimer()
        
        XCTAssertEqual(spy.pauseCountCallCount, 1)
    }
    
    // MARK: - helpers
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalTimer, spy: TimerSpy) {
        let spy = TimerSpy()
        let sut = LocalTimer(timer: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
}
