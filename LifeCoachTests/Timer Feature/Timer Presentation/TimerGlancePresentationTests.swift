import XCTest
import LifeCoach

class TimerGlancePresentation {
    enum Event {
        case showIdle
    }
    
    var onShowEvent: (() -> Void)?
    
    
    func check(timerState: TimerState) {
        
    }
}

final class TimerGlancePresentationTests: XCTestCase {
    func test_checkTimerState_onPauseTimerStateSendsShowIdle() {
        let pauseState = TimerState(elapsedSeconds: makeAnyLocalTimerSet().model, state: .pause)
        let sut = TimerGlancePresentation()
        var result = resultOnStatusCheck(from: sut)
        
        sut.check(timerState: pauseState)
        
        XCTAssertEqual(result, .showIdle)
    }
    
    // MARK: - Helpers
    private func resultOnStatusCheck(from: TimerGlancePresentation) -> TimerGlancePresentation.Event{
        .showIdle
    }
}
