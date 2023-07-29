import XCTest
import LifeCoach

extension LocalTimerState: CustomStringConvertible {
    public var description: String {
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
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: SaveTimerState, spy: LocaTimerSpy) {
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func expect(_ sut: SaveTimerState, toFinishWithError expectedError: NSError?, when action: () -> Void,
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
}
