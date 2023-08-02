import XCTest

protocol TimerStoreNotifier {
    func storeSaved()
}

class DefaultTimerStoreNotifier: TimerStoreNotifier {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func storeSaved() {
        completion()
    }
}

final class TimerStoreNotifierTests: XCTestCase {
    func test_init_doesNotExecuteCompletion() {
        var completionCallCount = 0
        let _ = makeSUT(completion: { completionCallCount += 1 })
        
        XCTAssertEqual(completionCallCount, 0, "should not call completion on init")
    }
    
    func test_storeSaved_executesCompletion() {
        var completionCallCount = 0
        let sut = makeSUT(completion: { completionCallCount += 1 })
        
        sut.storeSaved()
        
        XCTAssertEqual(completionCallCount, 1, "should call completion once")
    }
    
    // MARK: - Helper
    func makeSUT(completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) -> TimerStoreNotifier {
        let sut = DefaultTimerStoreNotifier(completion: completion)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
}
