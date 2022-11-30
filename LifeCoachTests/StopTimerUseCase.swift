import LifeCoach
import XCTest

final class StopTimerUseCase: XCTestCase {
    func test_init_doesNotSendAnyMessageToTimer() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.stopCallCount, 0)
    }
    
    func test_stopTimer_sendsMessageToTimer() {
        let (sut, spy) = makeSUT()
        sut.stopTimer() { _ in }
        
        XCTAssertEqual(spy.stopCallCount, 1)
    }
    
    func test_stopTimer_returnsCorrectElapsedSeconds() {
        let (sut, spy) = makeSUT()
        var received: ElapsedSeconds?
        sut.stopTimer() { elapsedTime in
            received = elapsedTime
        }
    
        let expectedElapsedTime = makeElapsedSeconds()
        
        spy.finishStopWith(date: expectedElapsedTime.local)
        
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
}
