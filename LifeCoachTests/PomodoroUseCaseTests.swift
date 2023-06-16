import XCTest
import LifeCoach

class PomodoroTimer {
    private let timer: TimerSpy
    private let timeReceiver: (Result) -> Void
    
    enum Error: Swift.Error {
        case timerError
    }
    
    typealias Result = Swift.Result<ElapsedSeconds, Error>
    
    init(timer: TimerSpy, timeReceiver: @escaping (Result) -> Void) {
        self.timer = timer
        self.timeReceiver = timeReceiver
    }
    
    func start() {
        timer.startCountdown() { [unowned self] result in
            switch result {
            case let .success(localElapsedSeconds):
                self.timeReceiver(.success(localElapsedSeconds.toElapseSeconds))
            case .failure:
                self.timer.stopCountdown()
                self.timeReceiver(.failure(.timerError))
            }
        }
    }
    
    func pause() {
        timer.pauseCountdown()
    }
    
    func stop() {
        timer.stopCountdown()
    }
}

class TimerSpy {
    private(set) var messagesReceived = [TimerCountdownMessages]()
    enum TimerCountdownMessages {
        case start
        case stop
        case pause
    }
    // MARK: - StartCoundown methods
    typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    private var startCountdownCompletions = [StartCoundownCompletion]()
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        messagesReceived.append(.start)
        startCountdownCompletions.append(completion)
    }
    
    func failsTimerWith(error: NSError, at index: Int = 0) {
        startCountdownCompletions[index](.failure(error))
    }
    
    func delivers(time localTime: LocalElapsedSeconds, at index: Int = 0) {
        startCountdownCompletions[index](.success(localTime))
    }
    
    // MARK: - StopCountdown methods
    func stopCountdown() {
        messagesReceived.append(.stop)
    }
    
    // MARK: - PauseCoutdown methods
    func pauseCountdown() {
        messagesReceived.append(.pause)
    }
}

final class PomodoroUseCaseTests: XCTestCase {
    func test_init_doesNotSendsMessageToTimerCountdownOnInit() {
        let (_, spy) = makeSUT()
        XCTAssertEqual(spy.messagesReceived, [])
    }
    
    func test_start_sendsStartMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.start()
        
        XCTAssertEqual(spy.messagesReceived, [.start])
    }
    
    func test_start_deliversTimerErrorOnTimerCountdownError() {
        var recievedResult: PomodoroTimer.Result?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            recievedResult = result
        })
        
        sut.start()
        spy.failsTimerWith(error: anyNSError())
        
        assert(recievedResult: recievedResult!, ToBe: .failure(.timerError))
    }
    
    func test_start_sendsStopMessageToTimerCountdownOnTimerCountdownError() {
        let (sut, spy) = makeSUT()
        
        sut.start()
        
        spy.failsTimerWith(error: anyNSError())
        
        XCTAssertEqual(spy.messagesReceived, [.start, .stop])
    }
    
    func test_start_deliversElapsedSecondsOnTimerCountdownSuccessDelivery() {
        var recievedResult: PomodoroTimer.Result?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            recievedResult = result
        })
        let startTime = Date()
        let expectedDeliveredTime = makeDeliveredTime(1, startDate: startTime, endDate: startTime.adding(seconds: .pomodoroInSeconds))
        
        sut.start()
        spy.delivers(time: expectedDeliveredTime.local)
        
        assert(recievedResult: recievedResult!, ToBe: .success(expectedDeliveredTime.model))
    }
    
    func test_pause_sendsPauseMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.pause()
        
        XCTAssertEqual(spy.messagesReceived, [.pause])
    }
    
    func test_stop_sendsStopMessageToTimerCountdown() {
        let (sut, spy) = makeSUT()
        
        sut.stop()
        
        XCTAssertEqual(spy.messagesReceived, [.stop])
    }
    
    // MARK: - Helper
    private func assert(recievedResult result: PomodoroTimer.Result, ToBe expectedResult: PomodoroTimer.Result) {
        switch (result, expectedResult) {
        case let (.success(timeDelivered), .success(expectedTimeDelivered)):
            XCTAssertEqual(timeDelivered, expectedTimeDelivered)
        case let (.failure(error), .failure(expectedError)):
            XCTAssertEqual(error, expectedError)
        case (.failure, .success), (.success, .failure):
            XCTFail("expected \(expectedResult), got \(result)")
        }
    }
    
    private func makeDeliveredTime(_ elapsedSeconds: TimeInterval,
                                   startDate: Date,
                                   endDate: Date) -> (model: ElapsedSeconds, local: LocalElapsedSeconds) {
        let model = ElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
        let local = LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
        return (model, local)
    }
    
    private func makeSUT(timeReceiver: ((PomodoroTimer.Result) -> Void)? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (PomodoroTimer, TimerSpy) {
        let spy = TimerSpy()
        let sut = PomodoroTimer(timer: spy, timeReceiver: timeReceiver ?? { _ in })
        
        trackForMemoryLeak(instance: spy, file: file, line: line)
        trackForMemoryLeak(instance: sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 1)
    }
}
