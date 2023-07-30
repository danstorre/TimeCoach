import Foundation
import LifeCoach

class LocaTimerSpy: LocalTimerStore {
    private(set) var deleteMessageCount = 0
    private(set) var receivedMessages = [AnyMessage]()
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrieveResult: Result<LocalTimerState, Error>?
    
    enum AnyMessage: Equatable, CustomStringConvertible {
        case deleteState
        case insert(state: LocalTimerState)
        case retrieve
        
        var description: String {
            switch self {
            case .deleteState:
                return "deleteState"
            case let .insert(state: localTimerSet):
                return "insert: \(localTimerSet)"
            case .retrieve:
                return "retrieve"
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
    
    // MARK: State Retrieval
    private struct UnexpectedError: Error {}
    
    func retrieve() throws -> LifeCoach.LocalTimerState {
        receivedMessages.append(.retrieve)
        return try (retrieveResult ?? .failure(UnexpectedError())).get()
    }
    
    func failRetrieve(with error: NSError) {
        retrieveResult = .failure(error)
    }
    
    func completesRetrieveSuccessfully(with state: LocalTimerState) {
        retrieveResult = .success(state)
    }
}
