import XCTest
import LifeCoach

final class TimerPresentationTests: XCTestCase {

    func test_init_noneMode_setsTimerStringToEmpty() {
        let sut = TimerViewModel()
        sut.mode = .none
        
        XCTAssertEqual(sut.timerString, .emptyTimer)
    }
    
    func test_init_fullMode_setsTimerStringToDefaultPomodoroString() {
        let sut = TimerViewModel()
        
        XCTAssertEqual(sut.timerString, elapsedSecondsFromPomodoro(0).toString(mode: .full))
    }
    
    func test_init_modeIsFull() {
        let sut = TimerViewModel()
        
        XCTAssertEqual(sut.mode, .full)
    }
    
    func test_delivered_onNoneMode_setsTimerStringToEmpty() {
        let sut = TimerViewModel()
        sut.mode = .none
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(0))
        
        XCTAssertEqual(sut.timerString, .emptyTimer)
    }
    
    func test_delivered_onFullMode_setsTimerStringToDeliveredTimer() {
        let sut = TimerViewModel()
        
        let deliveredTime = elapsedSecondsFromPomodoro(0)
        sut.delivered(elapsedTime: deliveredTime)
        
        XCTAssertEqual(sut.timerString, deliveredTime.toString(mode: .full))
    }
    
    func test_timerString_onFullmode_afterNoneMode_setsTimerStringToCurrentTimer() {
        let sut = TimerViewModel()
        sut.mode = .none
        sut.mode = .full
        
        XCTAssertEqual(sut.timerString, elapsedSecondsFromPomodoro(0).toString(mode: .full))
    }
    
    func test_timerString_onNoneMode_afterFullMode_setsTimerStringToEmpty() {
        let sut = TimerViewModel()
        sut.mode = .full
        sut.mode = .none
        
        XCTAssertEqual(sut.timerString, .emptyTimer)
    }
    
    func test_delivered_onFullMode_afterNoneMode_setsTimerStringToCurrentTimer() {
        let sut = TimerViewModel()
        sut.mode = .none
        XCTAssertEqual(sut.timerString, .emptyTimer)
        
        let deliveredTime2 = elapsedSecondsFromPomodoro(1)
        sut.delivered(elapsedTime: deliveredTime2)
        XCTAssertEqual(sut.timerString, .emptyTimer)
        
        sut.mode = .full
        XCTAssertEqual(sut.timerString, deliveredTime2.toString(mode: .full))
    }
    
    func test_delivered_onNoneMode_afterFullMode_setsTimerStringToEmpty() {
        let sut = TimerViewModel()
        sut.mode = .full
        XCTAssertEqual(sut.timerString, elapsedSecondsFromPomodoro(0).toString(mode: .full))
        
        let deliveredTime2 = elapsedSecondsFromPomodoro(1)
        sut.delivered(elapsedTime: deliveredTime2)
        XCTAssertEqual(sut.timerString, elapsedSecondsFromPomodoro(1).toString(mode: .full))
        
        sut.mode = .none
        XCTAssertEqual(sut.timerString, .emptyTimer)
    }
    
    private func elapsedSecondsFromPomodoro(_ seconds: TimeInterval) -> ElapsedSeconds {
        let now = Date.now
        return ElapsedSeconds(seconds, startDate: now, endDate: now.adding(seconds: .pomodoroInSeconds))
    }
    
    private func elapsedSecondsFromBreak(_ seconds: TimeInterval) -> ElapsedSeconds {
        let now = Date.now
        return ElapsedSeconds(seconds, startDate: now, endDate: now.adding(seconds: .breakInSeconds))
    }

}

fileprivate extension String {
    static var emptyTimer: String { "--:--" }
}

fileprivate extension ElapsedSeconds {
    func toString(mode: TimerViewModel.TimePresentation) -> String {
        makeTimerFormatter().string(from: startDate, to: endDate.adding(seconds: -elapsedSeconds))!
    }
}
