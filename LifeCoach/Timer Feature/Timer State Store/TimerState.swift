import Foundation

public struct TimerState: Equatable {
    public enum State {
        case pause
        case running
        case stop
    }
    public let timerSet: TimerSet
    public let state: State
    
    public init(timerSet: TimerSet, state: TimerState.State) {
        self.timerSet = timerSet
        self.state = state
    }
}
