import XCTest

class LocalTimer {
    private let store: LocaTimerSpy
    init(store: LocaTimerSpy) {
        self.store = store
    }
}

class LocaTimerSpy {
    var retrieveMessageCount = 0
}

final class TimerSaveStateUseCaseTests: XCTestCase {
    func test_init_doesNotSendRetrieveCommandToStore() {
        let spy = LocaTimerSpy()
        let _ = LocalTimer(store: spy)
        
        XCTAssertEqual(spy.retrieveMessageCount, 0)
    }
}
