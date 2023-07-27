import XCTest
import LifeCoach

class LocalTimer {
    private let store: LocaTimerSpy
    init(store: LocaTimerSpy) {
        self.store = store
    }
    
    func save(elapsedSeconds: ElapsedSeconds) throws {
        store.deleteState()
    }
}

class LocaTimerSpy {
    private(set) var deleteMessageCount = 0
    
    func deleteState() {
        deleteMessageCount += 1
    }
    
    func failDeletion(with error: NSError) {
        
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
        
        try? sut.save(elapsedSeconds: anyElapsedSeconds)
        
        XCTAssertEqual(spy.deleteMessageCount, 1)
    }
    
    func test_save_onStoreDeletionErrorShouldDeliverError() {
        let anyElapsedSeconds = makeAnyLocalElapsedSeconds()
        let expectedError = anyNSError()
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        spy.failDeletion(with: expectedError)
        
        do {
            try sut.save(elapsedSeconds: anyElapsedSeconds)
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    // MARK:- Helper Methods
    private func makeAnyLocalElapsedSeconds(seconds: TimeInterval = 1, startDate: Date = Date(), endDate: Date = Date()) -> ElapsedSeconds {
        ElapsedSeconds(seconds, startDate: startDate, endDate: endDate)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 1)
    }
}
