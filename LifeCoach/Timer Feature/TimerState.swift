import Foundation

public struct TimerState: Equatable {
    public enum State {
        case pause
        case running
        case stop
    }
    public let timerSet: TimerSet
    public let state: State
    public let isBreak: Bool
    
    public init(timerSet: TimerSet, state: TimerState.State, isBreak: Bool = false) {
        self.timerSet = timerSet
        self.state = state
        self.isBreak = isBreak
    }
}
