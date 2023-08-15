import LifeCoach
import XCTest

final class TimerLoadTests: XCTestCase {
    func test_init_doesNotSendRetrieveCommandToStore() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    func test_load_sendRetrieveMessageToStore() {
        let (sut, spy) = makeSUT()
        
        _ = try? sut.load()
        
        XCTAssertEqual(spy.receivedMessages, [.retrieve])
    }
    
    func test_load_onEmptyStoreDeliversEmpty() {
        let (sut, spy) = makeSUT()
        spy.completesRetrieveSuccessfully(with: nil)
        
        let result = try? sut.load()
        
        XCTAssertNil(result, "sut should have return empty")
    }
    
    func test_load_onStoreRetrieveFailureDeliversError() {
        let (sut, spy) = makeSUT()
        let expectedError = anyNSError()
        spy.failRetrieve(with: expectedError)
        
        do {
            _ = try sut.load()
            
            XCTFail("Should have throw an error: \(expectedError).")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func test_load_onStoreRetrieveSuccessDeliversTimerState() throws {
        let isBreakSamples = [false, true]
        
        try isBreakSamples.forEach { sample in
            let (sut, spy) = makeSUT()
            let state = makeAnyState(isBreak: sample)
            spy.completesRetrieveSuccessfully(with: state.local)
            
            let result = try sut.load()
            
            XCTAssertEqual(result, state.model)
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
