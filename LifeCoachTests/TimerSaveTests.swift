import XCTest
import LifeCoach

class LocalTimer {
    private let store: LocaTimerSpy
    init(store: LocaTimerSpy) {
        self.store = store
    }
    
    func save(elapsedSeconds: ElapsedSeconds) {
        store.deleteElapsedSeconds()
    }
}

class LocaTimerSpy {
    private(set) var deleteMessageCount = 0
    
    func deleteElapsedSeconds() {
        deleteMessageCount += 1
    }
}

final class TimerSaveStateUseCaseTests: XCTestCase {
    func test_init_doesNotSendDeleteCommandToStore() {
        let spy = LocaTimerSpy()
        let _ = LocalTimer(store: spy)
        
        XCTAssertEqual(spy.deleteMessageCount, 0)
    }
    
    func test_save_sendsDeleteMessageToStore() {
        let anyElapsedSeconds = makeAnyLocalElapsedSeconds()
        let spy = LocaTimerSpy()
        let sut = LocalTimer(store: spy)
        
        sut.save(elapsedSeconds: anyElapsedSeconds)
        
        XCTAssertEqual(spy.deleteMessageCount, 1)
    }
    
    private func makeAnyLocalElapsedSeconds(seconds: TimeInterval = 1, startDate: Date = Date(), endDate: Date = Date()) -> ElapsedSeconds {
        ElapsedSeconds(seconds, startDate: startDate, endDate: endDate)
    }
}
