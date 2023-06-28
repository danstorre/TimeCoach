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
        
        XCTAssertEqual(sut.timerString, .emptyTimer)
    }
    
    func test_delivered_fullMode_setsTimerStringToDeliveredTimer() {
        let sut = TimerViewModel()
        
        let deliveredTime = elapsedSecondsFromPomodoro(0)
        sut.delivered(elapsedTime: deliveredTime)
        
        XCTAssertEqual(sut.timerString, deliveredTime.toString(mode: .full, afterSeconds: 0))
    }
    
    func test_init_noneMode_setsTimerStringToEmpty() {
        let sut = TimerViewModel()
        sut.mode = .none
        
        XCTAssertEqual(sut.timerString, .emptyTimer)
    }
    
    func test_init_fullMode_setsTimerStringToDefaultPomodoroString() {
        let sut = TimerViewModel()
        
        XCTAssertEqual(sut.timerString, elapsedSecondsFromPomodoro(0).toString(mode: .full, afterSeconds: 0.0))
    }
    
    func test_init_modeIsFull() {
        let sut = TimerViewModel()
        
        XCTAssertEqual(sut.mode, .full)
    }
    
    func test_timerString_onfullmode_afterNoneMode_setsTimerStringToCurrentTimer() {
        let sut = TimerViewModel()
        sut.mode = .none
        sut.mode = .full
        
        XCTAssertEqual(sut.timerString, elapsedSecondsFromPomodoro(0).toString(mode: .full, afterSeconds: 0))
    }
    
    func test_timerString_onNoneMode_afterFullMode_setsTimerStringToEmpty() {
        let sut = TimerViewModel()
        sut.mode = .full
        sut.mode = .none
        
        XCTAssertEqual(sut.timerString, .emptyTimer)
    }
    
    func test_delivered_onFullMode_afterNone_setsTimerStringToCurrentTimer() {
        let sut = TimerViewModel()
        sut.mode = .none
        XCTAssertEqual(sut.timerString, .emptyTimer)
        
        let elapsedSeconds2: TimeInterval = 1.0
        let deliveredTime2 = elapsedSecondsFromPomodoro(elapsedSeconds2)
        sut.delivered(elapsedTime: deliveredTime2)
        XCTAssertEqual(sut.timerString, .emptyTimer)
        
        sut.mode = .full
        XCTAssertEqual(sut.timerString, deliveredTime2.toString(mode: .full, afterSeconds: elapsedSeconds2))
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
    func toString(mode: TimerViewModel.TimePresentation, afterSeconds seconds: TimeInterval) -> String {
        makeTimerFormatter().string(from: startDate, to: endDate.adding(seconds: -seconds))!
    }
}
