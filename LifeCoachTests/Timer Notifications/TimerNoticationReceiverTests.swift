import LifeCoach
import XCTest

final class TimerNoticationReceiverTests: XCTestCase {
    func test_init_doesNotExecuteCompletion() throws {
        var executedCompletion = 0
        let _ = makeSUT(completion: { executedCompletion += 1 })
        
        XCTAssertEqual(executedCompletion, 0)
    }
    
    func test_receivingNotification_executesCompletion() {
        var executedCompletion = 0
        let sut = makeSUT(completion: { executedCompletion += 1 })
        
        sut.receiveNotification()
        
        XCTAssertEqual(executedCompletion, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(completion: @escaping () -> Void) -> TimerNotificationReceiver {
        let sut = DefaultTimerNotificationReceiver(completion: completion)
        
        trackForMemoryLeak(instance: sut)
        
        return sut
    }
}
