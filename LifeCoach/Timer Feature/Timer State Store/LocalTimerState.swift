import Foundation

public struct LocalTimerState: Equatable {
    public enum State {
        case pause
        case running
        case stop
    }
    public let localTimerSet: TimerCountdownSet
    public let state: State
    public let isBreak: Bool
    
    public init(localTimerSet: TimerCountdownSet, state: LocalTimerState.State, isBreak: Bool = false) {
        self.localTimerSet = localTimerSet
        self.state = state
        self.isBreak = isBreak
    }
}
