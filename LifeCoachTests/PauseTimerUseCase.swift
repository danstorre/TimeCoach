import LifeCoach
import XCTest

final class PauseTimerUseCase: XCTestCase {
    func test_init_doesNotSendAnyMessageToTimer() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.pauseCountCallCount, 0)
    }
    
    func test_pauseTimer_sendsMessageToTimer() {
        let (sut, spy) = makeSUT()
        sut.pauseTimer() { _ in }
        
        XCTAssertEqual(spy.pauseCountCallCount, 1)
    }
    
    func test_pauseTimer_returnsCorrectElapsedSeconds() {
        let (sut, spy) = makeSUT()
        var received: ElapsedSeconds?
        sut.pauseTimer() { elapsedTime in
            received = elapsedTime
        }
    
        let expectedElapsedTime = makeElapsedSeconds()
        
        spy.finishPauseWith(date: expectedElapsedTime.local)
        
        XCTAssertEqual(received, expectedElapsedTime.model)
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
    
    private func makeElapsedSeconds(
        _ seconds: TimeInterval = 0,
        startDate: Date = .now,
        endDate: Date = .now
    ) -> (model: ElapsedSeconds, local: LocalElapsedSeconds) {
        (ElapsedSeconds(seconds, startDate: startDate, endDate: endDate), LocalElapsedSeconds(seconds, startDate: startDate, endDate: endDate))
    }
}
