import XCTest
import LifeCoach

final class TimerPresentationTests: XCTestCase {

    func test_init_setsTimerStringToEmpty() {
        let sut = makeSUT()
        XCTAssertEqual(sut.timerString, .emptyTimer)
    }
    
    func test_init_setsTimerStringToDefaultPomodoroString() {
        let sut = makeSUT()
        XCTAssertEqual(sut.timerString, elapsedSecondsFromPomodoro(0).toString())
    }
    
    func test_delivered_setsTimerStringToDeliveredTimer() {
        let sut = makeSUT()
        
        let deliveredTime = elapsedSecondsFromPomodoro(0)
        sut.delivered(elapsedTime: deliveredTime)
        
        XCTAssertEqual(sut.timerString, deliveredTime.toString())
    }
    
    private func elapsedSecondsFromPomodoro(_ seconds: TimeInterval) -> TimerSet {
        let now = Date.now
        return TimerSet(seconds, startDate: now, endDate: now.adding(seconds: .pomodoroInSeconds))
    }
    
    private func makeSUT() -> TimerViewModel {
        TimerViewModel(isBreak: false)
    }
}

fileprivate extension String {
    static var emptyTimer: String { "--:--" }
}

fileprivate extension TimerSet {
    func toString() -> String {
        makeTimerFormatter().string(from: startDate, to: endDate.adding(seconds: -elapsedSeconds))!
    }
}
