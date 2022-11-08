import XCTest

class StarTimer {
    private let infrastructure: InfraSpy
    
    init(infrastructure: InfraSpy) {
        self.infrastructure = infrastructure
    }
    
    func startTimer() {
        infrastructure.startCountdown()
    }
}

class InfraSpy {
    private(set) var callCount = 0
    
    func startCountdown() {
        callCount += 1
    }
}

final class StartTimerUseCase: XCTestCase {
    func test_init_doesNotSendAnyMessageToInfra() {
        let infrastructure = InfraSpy()
        let _ = StarTimer(infrastructure: infrastructure)
        
        XCTAssertEqual(infrastructure.callCount, 0)
    }
    
    func test_startTimer_sendsMessageToInfra() {
        let infrastructure = InfraSpy()
        let sut = StarTimer(infrastructure: infrastructure)
        sut.startTimer()
        
        XCTAssertEqual(infrastructure.callCount, 1)
    }
}
