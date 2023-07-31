@testable import LifeCoach
import XCTest


class TimerNotificationReceiver {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func receiveNotification() {
        completion()
    }
}

final class TimerNoticationReceiverTests: XCTestCase {
    func test_init_doesNotExecuteCompletion() throws {
        var executedCompletion = 0
        let completion: () -> Void = { executedCompletion += 1 }
        let _ = TimerNotificationReceiver(completion: completion)
        
        XCTAssertEqual(executedCompletion, 0)
    }
    
    func test_receivingNotification_executesCompletion() {
        var executedCompletion = 0
        let completion: () -> Void = { executedCompletion += 1 }
        let sut = TimerNotificationReceiver(completion: completion)
        
        sut.receiveNotification()
        
        XCTAssertEqual(executedCompletion, 1)
    }
}
