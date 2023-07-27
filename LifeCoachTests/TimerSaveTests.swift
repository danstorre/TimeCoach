import XCTest
import LifeCoach

struct TimerState {
    let elapsedSeconds: ElapsedSeconds
}

class LocalTimer {
    private let store: LocaTimerSpy
    init(store: LocaTimerSpy) {
        self.store = store
    }
    
    func save(state: TimerState) throws {
        store.deleteState()
        store.insert(state: state.local)
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
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.deleteMessageCount, 0)
    }
    
    func test_save_sendsDeleteStateMessageToStore() {
        let anyTimerState = makeAnyState()
        let (sut, spy) = makeSUT()
        
        try? sut.save(state: anyTimerState.model)
        
        XCTAssertEqual(spy.deleteMessageCount, 1)
    }
    
    func test_save_onStoreDeletionErrorShouldDeliverError() {
        let anyTimerState = makeAnyState()
        let expectedError = anyNSError()
        let (sut, spy) = makeSUT()
        spy.failDeletion(with: expectedError)
        
        do {
            try sut.save(state: anyTimerState.model)
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func test_save_onStoreDeletionSucces_sendMessageInsertionWithCorrectStateToStore() {
        let anyTimerState = makeAnyState()
        let (sut, spy) = makeSUT()
        spy.completesDeletionSuccessfully()
        
        try? sut.save(state: anyTimerState.model)
        
        XCTAssertEqual(spy.receivedMessages, [.deleteState, .insert(state: anyTimerState.local)])
    }
    
    // MARK:- Helper Methods
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalTimer, spy: LocaTimerSpy) {
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
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
}
