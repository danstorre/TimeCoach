import Foundation

public class PomodoroTimer: RegularTimer {
    private let timer: TimerCountdown
    private let timeReceiver: (Result) -> Void
    
    public enum Error: Swift.Error {
        case timerError
    }
    
    public typealias Result = Swift.Result<TimerState, Error>
    
    public init(timer: TimerCountdown, timeReceiver: @escaping (Result) -> Void) {
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
    
    private func stopCountDownOnFailure(result: TimerCountdown.Result) {
        if case .failure = result {
            self.timer.stopCountdown()
        }
    }
    
    private static func resolveResult(result: TimerCountdown.Result) -> Result {
        switch result {
        case let .success((localTimerSet, localState)):
            return .success(TimerState(timerSet: localTimerSet.toModel, state: localState.model))
        case .failure:
            return .failure(.timerError)
        }
    }
}


private extension TimerCountdownStateValues {
    var model: TimerState.State {
        switch self {
        case .pause: return .pause
        case .stop: return .stop
        case .running: return .running
        }
    }
}
