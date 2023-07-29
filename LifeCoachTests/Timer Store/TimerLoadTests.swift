import LifeCoach
import XCTest

final class TimerLoadTests: XCTestCase {
    func test_init_doesNotSendRetrieveCommandToStore() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    func test_load_sendRetrieveMessageToStore() {
        let (sut, spy) = makeSUT()
        
        sut.load()
        
        XCTAssertEqual(spy.receivedMessages, [.retrieve])
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
