import LifeCoach
import XCTest

final class TimerLoadTests: XCTestCase {
    func test_init_doesNotSendRetrieveCommandToStore() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    func test_load_sendRetrieveMessageToStore() {
        let (sut, spy) = makeSUT()
        
        try? sut.load()
        
        XCTAssertEqual(spy.receivedMessages, [.retrieve])
    }
    
    func test_load_onStoreRetrieveFailure_DeliversError() {
        let (sut, spy) = makeSUT()
        let expectedError = anyNSError()
        spy.failRetrieve(with: expectedError)
        
        do {
            try sut.load()
            
            XCTFail("Should have throw an error: \(expectedError).")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    // MARK:- Helper Methods
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LoadTimerState, spy: LocaTimerSpy) {
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
}
