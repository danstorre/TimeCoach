import LifeCoach
import XCTest

class PomodoroLocalTimer {
    private let handler: (LocalElapsedSeconds) -> Void
    
    init(handler: @escaping (LocalElapsedSeconds) -> Void) {
        self.handler = handler
    }
}

final class PomodoroLocalTimerTests: XCTestCase {
    
    func test_init_doesNotDeliverEstimatedTime() {
        var received: LocalElapsedSeconds?
        let completion: (LocalElapsedSeconds) -> Void = { timeElapsed in
            received = timeElapsed
        }
        let _ = PomodoroLocalTimer(handler: completion)
        
        XCTAssertNil(received)
    }
}
