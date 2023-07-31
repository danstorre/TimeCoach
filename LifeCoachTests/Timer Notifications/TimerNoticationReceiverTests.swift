@testable import LifeCoach
import XCTest


class TimerNotificationReceiver {
    
    init(completion: @escaping () -> Void) {
        
    }
}

final class TimerNoticationReceiverTests: XCTestCase {
    func test_init_doesNotExecuteCompletion() throws {
        var executedCompletion = 0
        let completion: () -> Void = { executedCompletion += 1 }
        let _ = TimerNotificationReceiver(completion: completion)
        
        XCTAssertEqual(executedCompletion, 0)
    }
}
