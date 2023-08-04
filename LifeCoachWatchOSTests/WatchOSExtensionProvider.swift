import XCTest
import WidgetKit
import LifeCoach

class WatchOSProvider {
    private let stateLoader: LoadTimerState
    init(stateLoader: LoadTimerState) {
        self.stateLoader = stateLoader
    }
    
    func getTimeline() {
        _ = try? stateLoader.load()
    }
}

class Spy: LoadTimerState {
    private(set) var loadStateCallCount = 0
    func load() throws -> LifeCoach.TimerState? {
        loadStateCallCount += 1
        return .none
    }
}

final class WatchOSExtensionProvider: XCTestCase {
    func test_getTimeline_messagesLoadState() {
        let spy = Spy()
        let sut = WatchOSProvider(stateLoader: spy)
        
        sut.getTimeline()
        
        XCTAssertEqual(spy.loadStateCallCount, 1, "should have called load state")
    }
}
