import XCTest
import LifeCoach

class LocalTimer {
    private let store: LocaTimerSpy
    init(store: LocaTimerSpy) {
        self.store = store
    }
    
    func save(elapsedSeconds: ElapsedSeconds) throws {
        store.deleteState()
        store.insert(state: LocalTimerState(localElapsedSeconds: elapsedSeconds.local))
    }
}

extension ElapsedSeconds {
    var local: LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
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

class LocaTimerSpy {
    private(set) var deleteMessageCount = 0
    
    private(set) var receivedMessages = [AnyMessage]()
    
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
    
    func deleteState() {
        deleteMessageCount += 1
        
        receivedMessages.append(.deleteState)
    }
    
    func failDeletion(with error: NSError) {
        
    }
    
    func completesDeletionSuccessfully() {
        
    }
    
    func insert(state: LocalTimerState) {
        receivedMessages.append(.insert(state: state))
    }
}

final class TimerSaveStateUseCaseTests: XCTestCase {
    func test_init_doesNotSendDeleteCommandToStore() {
        let spy = LocaTimerSpy()
        let _ = LocalTimer(store: spy)
        
        XCTAssertEqual(spy.deleteMessageCount, 0)
    }
    
    func test_save_sendsDeleteStateMessageToStore() {
        let anyElapsedSeconds = makeAnyLocalElapsedSeconds()
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        try? sut.save(elapsedSeconds: anyElapsedSeconds.model)
        
        XCTAssertEqual(spy.deleteMessageCount, 1)
    }
    
    func test_save_onStoreDeletionErrorShouldDeliverError() {
        let anyElapsedSeconds = makeAnyLocalElapsedSeconds()
        let expectedError = anyNSError()
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        spy.failDeletion(with: expectedError)
        
        do {
            try sut.save(elapsedSeconds: anyElapsedSeconds.model)
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func test_save_onStoreDeletionSucces_sendMessageInsertionWithCorrectStateToStore() {
        let anyElapsedSeconds = makeAnyLocalElapsedSeconds()
        let expectedLocalState = LocalTimerState(localElapsedSeconds: anyElapsedSeconds.local)
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        spy.completesDeletionSuccessfully()
        
        try? sut.save(elapsedSeconds: anyElapsedSeconds.model)
        
        XCTAssertEqual(spy.receivedMessages, [.deleteState, .insert(state: expectedLocalState)])
    }
    
    // MARK:- Helper Methods
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
}
