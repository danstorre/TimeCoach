import XCTest

class StarTimer {
    init(infrastructure: InfraSpy) {}
}

class InfraSpy {
    var countMessages = 0
}

final class StartTimerUseCase: XCTestCase {
    func test_init_doesNotSendAnyMessageToInfra() {
        let infrastructure = InfraSpy()
        let _ = StarTimer(infrastructure: infrastructure)
        
        XCTAssertEqual(infrastructure.countMessages, 0)
    }
}
