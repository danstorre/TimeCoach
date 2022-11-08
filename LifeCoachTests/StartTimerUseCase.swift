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
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_startTimer_sendsMessageToInfra() {
        let (sut, spy) = makeSUT()
        sut.startTimer()
        
        XCTAssertEqual(spy.callCount, 1)
    }
    
    // MARK: - helpers
    private func makeSUT() -> (sut: StarTimer,
                               spy: TimerSpy) {
        let spy = TimerSpy()
        let sut = StarTimer(timer: spy)
        
        return (sut, spy)
    }
}
