import XCTest

class StoreNotifier {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func storeSaved() {
        completion()
    }
}

final class StoreNotifierTests: XCTestCase {
    func test_init_doesNotExecuteCompletion() {
        var completionCallCount = 0
        let _ = StoreNotifier(completion: { completionCallCount += 1 })
        
        XCTAssertEqual(completionCallCount, 0, "should not call completion on init")
    }
    
    func test_storeSaved_executesCompletion() {
        var completionCallCount = 0
        let sut = makeSUT(completion: { completionCallCount += 1 })
        
        sut.storeSaved()
        
        XCTAssertEqual(completionCallCount, 1, "should call completion once")
    }
    
    // MARK: - Helper
    func makeSUT(completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) -> StoreNotifier {
        let sut = StoreNotifier(completion: completion)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return sut
    }
}
