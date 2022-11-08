import XCTest

class StarTimer {
    private let timer: TimerSpy
    
    init(timer: TimerSpy) {
        self.timer = timer
    }
    
    func startTimer() {
        timer.startCountdown()
    }
}

class TimerSpy {
    private(set) var callCount = 0
    
    func startCountdown() {
        callCount += 1
    }
}

final class StartTimerUseCase: XCTestCase {
    func test_init_doesNotSendAnyMessageToInfra() {
        let infrastructure = TimerSpy()
        let _ = StarTimer(timer: infrastructure)
        
        XCTAssertEqual(infrastructure.callCount, 0)
    }
    
    func test_startTimer_sendsMessageToInfra() {
        let infrastructure = TimerSpy()
        let sut = StarTimer(timer: infrastructure)
        sut.startTimer()
        
        XCTAssertEqual(infrastructure.callCount, 1)
    }
}
