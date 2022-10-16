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
    var messageCount = 0
    
    func start() {
        messageCount += 1
    }
}

final class StartTimerUseCase: XCTestCase {

    func test_init_doesNotSendsMessageToTimer() {
        let timer = TimerSpy()
        let _ = TimerStarter(timer: timer)
        
        XCTAssertEqual(timer.messageCount, 0)
    }
    
    func test_start_sendsStartMessageToTimer() {
        let timer = TimerSpy()
        let sut = TimerStarter(timer: timer)
        
        sut.startTimer()
        
        XCTAssertEqual(timer.messageCount, 1)
    }
}
