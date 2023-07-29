import LifeCoach
import XCTest

final class TimerLoadTests: XCTestCase {
    func test_init_doesNotSendRetrieveCommandToStore() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    // MARK:- Helper Methods
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: SaveTimerState, spy: LocaTimerSpy) {
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private class LocaTimerSpy: LocalTimerStore {
        private(set) var deleteMessageCount = 0
        private(set) var receivedMessages = [AnyMessage]()
        private var deletionResult: Result<Void, Error>?
        private var insertionResult: Result<Void, Error>?
        
        enum AnyMessage: Equatable, CustomStringConvertible {
            case deleteState
            case insert(state: LocalTimerState)
            
            var description: String {
                switch self {
                case .deleteState:
                    return "deleteState"
                case let .insert(state: localElapsedSeconds):
                    return "insert: \(localElapsedSeconds)"
                }
            }
        }
        
        // MARK: State Deletion
        func deleteState() throws {
            deleteMessageCount += 1
            receivedMessages.append(.deleteState)
            try deletionResult?.get()
        }
        
        func failDeletion(with error: NSError) {
            deletionResult = .failure(error)
        }
        
        func completesDeletionSuccessfully() {
            deletionResult = .success(())
        }
        
        // MARK: State Insertion
        func insert(state: LocalTimerState) throws {
            receivedMessages.append(.insert(state: state))
            try insertionResult?.get()
        }
        
        func failInsertion(with error: NSError) {
            insertionResult = .failure(error)
        }
        
        func completesInsertionSuccesfully() {
            insertionResult = .success(())
        }
    }
}
