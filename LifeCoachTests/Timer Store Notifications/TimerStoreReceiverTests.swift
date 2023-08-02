import LifeCoach
import XCTest

public class TimerStoreReceiverNotification: TimerStoreReceiver {
    private let completion: () -> Void
    
    public init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    public func receiveNotification() {
        completion()
    }
}

public protocol TimerStoreReceiver {
    func receiveNotification()
}

final class TimerStoreReceiverTests: XCTestCase {
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
    private func makeSUT(completion: @escaping () -> Void) -> TimerStoreReceiver {
        let sut = TimerStoreReceiverNotification(completion: completion)
        
        trackForMemoryLeak(instance: sut)
        
        return sut
    }
}
