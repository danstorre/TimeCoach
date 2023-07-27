import XCTest
import LifeCoach

class LocalTimer {
    private let store: LocaTimerSpy
    init(store: LocaTimerSpy) {
        self.store = store
    }
    
    func save(elapsedSeconds: ElapsedSeconds) {
        store.retrieveElapsedSeconds()
    }
}

class LocaTimerSpy {
    private(set) var retrieveMessageCount = 0
    
    func retrieveElapsedSeconds() {
        retrieveMessageCount += 1
    }
}

final class TimerSaveStateUseCaseTests: XCTestCase {
    func test_init_doesNotSendRetrieveCommandToStore() {
        let spy = LocaTimerSpy()
        let _ = LocalTimer(store: spy)
        
        XCTAssertEqual(spy.retrieveMessageCount, 0)
    }
    
    func test_save_sendsRetrieveMessageToStore() {
        let anyElapsedSeconds = makeAnyLocalElapsedSeconds()
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        sut.save(elapsedSeconds: anyElapsedSeconds)
        
        XCTAssertEqual(spy.retrieveMessageCount, 1)
    }
    
    private func makeAnyLocalElapsedSeconds(seconds: TimeInterval = 1, startDate: Date = Date(), endDate: Date = Date()) -> ElapsedSeconds {
        ElapsedSeconds(seconds, startDate: startDate, endDate: endDate)
    }
}
