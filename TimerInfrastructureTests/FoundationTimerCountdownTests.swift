import LifeCoach
import XCTest

class FoundationTimerCountdown {
    enum TimerState {
        case pause
    }
    
    var state: TimerState { .pause }
}

final class FoundationTimerCountdownTests: XCTestCase {
    func test_init_stateIsPaused() {
        let timerCountdown = FoundationTimerCountdown()
        XCTAssertEqual(timerCountdown.state, .pause)
    }
}
