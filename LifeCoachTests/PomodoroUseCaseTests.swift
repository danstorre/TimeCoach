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
}

class TimerSpy {
    private(set) var messagesReceived = [TimerCountdownMessages]()
    enum TimerCountdownMessages {
        case start
        case stop
    }
    
    typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    private var startCountdownCompletions = [StartCoundownCompletion]()
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        messagesReceived.append(.start)
        startCountdownCompletions.append(completion)
    }
    
    func failsTimerWith(error: NSError, at index: Int = 0) {
        startCountdownCompletions[index](.failure(error))
    }
    
    func stopCountdown() {
        messagesReceived.append(.stop)
    }
    
    func delivers(time localTime: LocalElapsedSeconds, at index: Int = 0) {
        startCountdownCompletions[index](.success(localTime))
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
        var receivedError: PomodoroTimer.Error?
        let (sut, spy) = makeSUT(timeReceiver: { result in
            switch result {
            case .success:
                XCTFail("should have failed")
            case let .failure(error):
                receivedError = error
            }
        })
        
        sut.start()
        
        spy.failsTimerWith(error: anyNSError())
        
        XCTAssertEqual(receivedError, .timerError)
    }
    
    func test_start_sendsStopMessageToTimerCountdownOnTimerCountdownError() {
        let (sut, spy) = makeSUT()
        
        sut.start()
        
        spy.failsTimerWith(error: anyNSError())
        
        XCTAssertEqual(spy.messagesReceived, [.start, .stop])
    }
    
    func test_start_deliversElapsedSecondsOnTimerCountdownSuccessDelivery() {
        let startTime = Date()
        let deliveredTime = makeDeliveredTime(1, startDate: startTime, endDate: startTime.adding(seconds: .pomodoroInSeconds))
        
        let (sut, spy) = makeSUT(timeReceiver: { result in
            switch result {
            case let .success(elapsedSeconds):
                XCTAssertEqual(elapsedSeconds, deliveredTime.model)
            case .failure:
                XCTFail("should have succeeded")
            }
        })
        
        sut.start()
        
        spy.delivers(time: deliveredTime.local)
    }
    
    // MARK: - Helpers
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
