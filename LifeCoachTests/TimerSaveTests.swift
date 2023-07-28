import XCTest
import LifeCoach

struct TimerState {
    let elapsedSeconds: ElapsedSeconds
}

protocol LocalTimerStore {
    func deleteState() throws
    func insert(state: LocalTimerState) throws
}

class LocalTimer {
    private let store: LocalTimerStore
    init(store: LocalTimerStore) {
        self.store = store
    }
    
    func save(state: TimerState) throws {
        try store.deleteState()
        try store.insert(state: state.local)
    }
}

extension ElapsedSeconds {
    var local: LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}

extension TimerState {
    var local: LocalTimerState {
        LocalTimerState(localElapsedSeconds: elapsedSeconds.local)
    }
}

struct LocalTimerState: Equatable {
    let localElapsedSeconds: LocalElapsedSeconds
}

extension LocalTimerState: CustomStringConvertible {
    var description: String {
        "localState: \(localElapsedSeconds)"
    }
}

final class TimerSaveStateUseCaseTests: XCTestCase {
    func test_init_doesNotSendDeleteCommandToStore() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    func test_save_onStoreDeletionError_doesNotSendInsertionMessageToStore() {
        let anyTimerState = makeAnyState()
        let expectedError = anyNSError()
        let (sut, spy) = makeSUT()
        spy.failDeletion(with: expectedError)
        
        try? sut.save(state: anyTimerState.model)
        
        XCTAssertEqual(spy.receivedMessages, [.deleteState])
    }
    
    func test_save_onStoreDeletionErrorShouldDeliverError() {
        let expectedError = anyNSError()
        let (sut, spy) = makeSUT()
        
        expect(sut, toFinishWithError: expectedError, when: {
            spy.failDeletion(with: expectedError)
        })
    }
    
    func test_save_onStoreDeletionSucces_sendMessageInsertionWithCorrectStateToStore() {
        let anyTimerState = makeAnyState()
        let (sut, spy) = makeSUT()
        spy.completesDeletionSuccessfully()
        
        try? sut.save(state: anyTimerState.model)
        
        XCTAssertEqual(spy.receivedMessages, [.deleteState, .insert(state: anyTimerState.local)])
    }
    
    func test_save_OnStoreInsertionErrorShouldDeliverError() {
        let expectedError = anyNSError()
        let (sut, spy) = makeSUT()
        
        expect(sut, toFinishWithError: expectedError, when: {
            spy.completesDeletionSuccessfully()
            spy.failInsertion(with: expectedError)
        })
    }
    
    func test_save_deliversSuccesOnDeletionAndInsertionSuccess() {
        let (sut, spy) = makeSUT()
        
        expect(sut, toFinishWithError: .none, when: {
            spy.completesDeletionSuccessfully()
            spy.completesInsertionSuccesfully()
        })
    }
    
    // MARK:- Helper Methods
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalTimer, spy: LocaTimerSpy) {
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func expect(_ sut: LocalTimer, toFinishWithError expectedError: NSError?, when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {
        action()
        
        do {
            try sut.save(state: makeAnyState().model)
        } catch {
            XCTAssertEqual(error as NSError, expectedError, file: file, line: line)
        }
    }
    
    private func makeAnyState(seconds: TimeInterval = 1,
                              startDate: Date = Date(),
                              endDate: Date = Date()) -> (model: TimerState, local: LocalTimerState) {
        let elapsedSeconds = makeAnyLocalElapsedSeconds(seconds: seconds, startDate: startDate, endDate: endDate)
        let model = TimerState(elapsedSeconds: elapsedSeconds.model)
        let local = LocalTimerState(localElapsedSeconds: elapsedSeconds.local)
        
        return (model, local)
    }
    
    private func makeAnyLocalElapsedSeconds(seconds: TimeInterval = 1,
                                            startDate: Date = Date(),
                                            endDate: Date = Date()) -> (model: ElapsedSeconds, local: LocalElapsedSeconds) {
        let modelElapsedSeconds = ElapsedSeconds(seconds, startDate: startDate, endDate: endDate)
        let localElapsedSeconds = LocalElapsedSeconds(seconds, startDate: startDate, endDate: endDate)
        
        return (modelElapsedSeconds, localElapsedSeconds)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 1)
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
