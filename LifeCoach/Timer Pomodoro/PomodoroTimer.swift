import Foundation

public class PomodoroTimer: RegularTimer {
    private let timer: TimerCoutdown
    private let timeReceiver: (Result) -> Void
    
    public enum Error: Swift.Error {
        case timerError
    }
    
    public typealias Result = Swift.Result<TimerSet, Error>
    
    public init(timer: TimerCoutdown, timeReceiver: @escaping (Result) -> Void) {
        self.timer = timer
        self.timeReceiver = timeReceiver
    }
    
    public func start() {
        timer.startCountdown() { [weak self] result in
            guard let self = self else { return }
            self.stopCountDownOnFailure(result: result)
            self.timeReceiver(Self.resolveResult(result: result))
        }
    }
    
    public func pause() {
        timer.pauseCountdown()
    }
    
    public func stop() {
        timer.stopCountdown()
    }
    
    public func skip() {
        timer.skipCountdown() { [weak self] result in
            guard let self = self else { return }
            self.stopCountDownOnFailure(result: result)
            self.timeReceiver(Self.resolveResult(result: result))
        }
    }
    
    private func stopCountDownOnFailure(result: TimerCoutdown.Result) {
        if case .failure = result {
            self.timer.stopCountdown()
        }
    }
    
    private static func resolveResult(result: TimerCoutdown.Result) -> Result {
        switch result {
        case let .success(localTimerSet):
            return .success(localTimerSet.toElapseSeconds)
        case .failure:
            return .failure(.timerError)
        }
    }
}
