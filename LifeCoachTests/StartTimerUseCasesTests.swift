import XCTest
import LifeCoach


final class StartTimerUseCase: XCTestCase {
    func test_init_doesNotSendAnyMessageToTimer() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_startTimer_sendsMessageToTimer() {
        let (sut, spy) = makeSUT()
        sut.startTimer() { _ in }
        
        XCTAssertEqual(spy.callCount, 1)
    }
    
    func test_startTimer_sendsCorrectPomodoroTimes() {
        let now = Date.now
        let pomodoroTime = now.adding(seconds: .pomodoroInSeconds)
        let (sut, spy) = makeSUT()
        sut.startTimer(from: now) { _ in }
        
        XCTAssertEqual(spy.startDatesReceived, [now])
        XCTAssertEqual(spy.endDatesReceived, [pomodoroTime])
    }
    
    func test_startTimer_twice_sendsCorrectPomodoroTimes() {
        let now = Date.now
        let pomodoroTime = now.adding(seconds: .pomodoroInSeconds)
        let (sut, spy) = makeSUT(primaryTime: .pomodoroInSeconds)
        sut.startTimer(from: now) { _ in }
        sut.startTimer(from: now) { _ in }
        
        XCTAssertEqual(spy.startDatesReceived, [now, now])
        XCTAssertEqual(spy.endDatesReceived, [pomodoroTime, pomodoroTime])
    }
    
    func test_starTimer_receivesCorrectElapsedTime() {
        let (sut, spy) = makeSUT()
        let now = Date.now
        let pomodoroTime = Date.now.adding(seconds: .pomodoroInSeconds)
        
        var received: ElapsedSeconds?
        sut.startTimer() { elapsedTime in
            received = elapsedTime
        }

        let expectedElapsedTime = makeElapsedSeconds(1,
                                                     startDate: now,
                                                     endDate: pomodoroTime)
        
        spy.deliversTime(with: expectedElapsedTime.local)
        
        XCTAssertEqual(received, expectedElapsedTime.model)
        
        let expectedElapsedTime2 = makeElapsedSeconds(2,
                                                     startDate: now,
                                                     endDate: pomodoroTime)
        
        spy.deliversTime(with: expectedElapsedTime2.local)
        
        XCTAssertEqual(received, expectedElapsedTime2.model)
    }
    
    // MARK: - helpers
    private func makeSUT(primaryTime: TimeInterval = .pomodoroInSeconds,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalTimer, spy: TimerSpy) {
        let spy = TimerSpy()
        let sut = LocalTimer(timer: spy, primaryTime: primaryTime)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
}
