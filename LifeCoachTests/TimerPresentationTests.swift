import XCTest
import LifeCoach

final class TimerPresentationTests: XCTestCase {

    func test_deliversCorrectTime() {
        let sut = TimerViewModel()
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(0))
        
        XCTAssertEqual(sut.timerString, "25:00")
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(1))
        
        XCTAssertEqual(sut.timerString, "24:59")
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(.pomodoroInSeconds + 1))
        
        XCTAssertEqual(sut.timerString, "00:00")
        
        sut.delivered(elapsedTime: elapsedSecondsFromBreak(.breakInSeconds + 1))
        
        XCTAssertEqual(sut.timerString, "00:00")
    }
    
    func test_timerString_OnNoneMode_deliversCorrectTimerString() {
        let sut = TimerViewModel()
        
        XCTAssertEqual(sut.timerString, "25:00")
        
        sut.mode = TimerViewModel.TimePresentation.none
        
        XCTAssertEqual(sut.timerString, "--:--")
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(0))
        
        XCTAssertEqual(sut.timerString, "--:--")
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(1))
        
        XCTAssertEqual(sut.timerString, "--:--")
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(61))
        
        XCTAssertEqual(sut.timerString, "--:--")
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(.pomodoroInSeconds + 1))
        
        XCTAssertEqual(sut.timerString, "00:00")
        
        sut.delivered(elapsedTime: elapsedSecondsFromBreak(.breakInSeconds + 1))
        
        XCTAssertEqual(sut.timerString, "00:00")
    }
    
    func test_onNoneMode_AfterFinish_setsCorrectTimerString() {
        let sut = TimerViewModel()
        
        XCTAssertEqual(sut.timerString, "25:00")
        
        sut.mode = TimerViewModel.TimePresentation.none
        
        XCTAssertEqual(sut.timerString, "--:--")
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(.pomodoroInSeconds + 1))
        
        XCTAssertEqual(sut.timerString, "00:00")
    }
    
    func test_delivered_OnNoneMode_setsTimerStringToEmpty() {
        let sut = TimerViewModel()
        sut.mode = .none
        
        sut.delivered(elapsedTime: elapsedSecondsFromPomodoro(0))
        
        XCTAssertEqual(sut.timerString, "--:--")
    }
    
    func test_delivered_fullMode_setsTimerStringToDeliveredTimer() {
        let sut = TimerViewModel()
        
        let deliveredTime = elapsedSecondsFromPomodoro(0)
        sut.delivered(elapsedTime: deliveredTime)
        
        XCTAssertEqual(sut.timerString, deliveredTime.toString(mode: .full))
    }
    
    func test_init_noneMode_setsTimerStringToEmpty() {
        let sut = TimerViewModel()
        sut.mode = .none
        
        XCTAssertEqual(sut.timerString, "--:--")
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

fileprivate extension ElapsedSeconds {
    func toString(mode: TimerViewModel.TimePresentation) -> String {
        makeTimerFormatter().string(from: startDate, to: endDate)!
    }
}
