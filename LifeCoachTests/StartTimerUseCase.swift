import XCTest

class TimerStarter {
    private let timer: TimerSpy
    init(timer: TimerSpy) {
        self.timer = timer
    }
    
    func startTimer() {
        timer.start()
    }
}

class TimerSpy {
    var startMessageCount = 0
    
    func start() {
        startMessageCount += 1
    }
}

final class StartTimerUseCase: XCTestCase {

    func test_init_doesNotSendsMessageToTimer() {
        let timer = TimerSpy()
        let _ = TimerStarter(timer: timer)
        
        XCTAssertEqual(timer.startMessageCount, 0)
    }
    
    func test_start_sendsStartMessageToTimer() {
        let timer = TimerSpy()
        let sut = TimerStarter(timer: timer)
        
        sut.startTimer()
        
        XCTAssertEqual(timer.startMessageCount, 1)
    }
}
