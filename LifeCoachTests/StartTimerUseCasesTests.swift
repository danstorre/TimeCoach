import XCTest
import LifeCoach

protocol StartTimer {
    func startCountdown(from date: Date, endDate: Date)
}

class LocalTimer {
    private let timer: StartTimer
    private var mode: TimerMode = .pomodoroTime
    private var isPomodoro = true
    
    enum TimerMode {
        case pomodoroTime
        case breakTime
    }
    
    init(timer: StartTimer) {
        self.timer = timer
    }
    
    func startTimer(from startDate: Date = .now) {
        let endTime: Date
        if isPomodoro {
            endTime = startDate.adding(seconds: .pomodoroInSeconds)
        } else {
            endTime = startDate.adding(seconds: .breakInSeconds)
        }
        
        isPomodoro = !isPomodoro
        
        timer.startCountdown(from: startDate,
                             endDate: endTime)
    }
}

final class StartTimerUseCase: XCTestCase {
    func test_init_doesNotSendAnyMessageToTimer() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_startTimer_sendsMessageToTimer() {
        let (sut, spy) = makeSUT()
        sut.startTimer()
        
        XCTAssertEqual(spy.callCount, 1)
    }
    
    func test_startTimer_sendsCorrectPomodoroTimes() {
        let now = Date.now
        let pomodoroTime = Date.now.adding(seconds: .pomodoroInSeconds)
        let (sut, spy) = makeSUT()
        sut.startTimer(from: now)
        
        XCTAssertEqual(spy.startDatesReceived, [now])
        XCTAssertEqual(spy.endDatesReceived, [pomodoroTime])
    }
    
    func test_startTimer_twice_sendsCorrectBreakTimes() {
        let now = Date.now
        let pomodoroTime = Date.now.adding(seconds: .pomodoroInSeconds)
        let breakTime = Date.now.adding(seconds: .breakInSeconds)
        let (sut, spy) = makeSUT()
        sut.startTimer(from: now)
        sut.startTimer(from: now)
        
        XCTAssertEqual(spy.startDatesReceived, [now, now])
        XCTAssertEqual(spy.endDatesReceived, [pomodoroTime, breakTime])
    }
    
    // MARK: - helpers
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalTimer, spy: TimerSpy) {
        let spy = TimerSpy()
        let sut = LocalTimer(timer: spy)
        
        trackForMemoryLeak(instance: sut, file: file, line: line)
        trackForMemoryLeak(instance: spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private class TimerSpy: StartTimer {
        private(set) var startDatesReceived = [Date]()
        private(set) var endDatesReceived = [Date]()
        var callCount: Int {
            startDatesReceived.count
        }
        
        func startCountdown(from date: Date, endDate: Date) {
            startDatesReceived.append(date)
            endDatesReceived.append(endDate)
        }
    }
}
