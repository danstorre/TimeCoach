import Foundation

public class PomodoroTimer: RegularTimer {
    private let timer: TimerCoutdown
    private let timeReceiver: (Result) -> Void
    
    public enum Error: Swift.Error {
        case timerError
    }
    
    public typealias Result = Swift.Result<ElapsedSeconds, Error>
    
    public init(timer: TimerCoutdown, timeReceiver: @escaping (Result) -> Void) {
        self.timer = timer
        self.timeReceiver = timeReceiver
    }
    
    public func start() {
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
    
    public func pause() {
        timer.pauseCountdown()
    }
    
    public func stop() {
        timer.stopCountdown()
    }
    
    public func skip() {
        timer.skipCountdown()
    }
}
