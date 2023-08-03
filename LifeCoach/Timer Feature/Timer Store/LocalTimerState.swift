import Foundation

public struct LocalTimerState: Equatable {
    public enum State {
        case pause
        case running
        case stop
    }
    let localTimerSet: LocalTimerSet
    let state: State
    
    public init(localTimerSet: LocalTimerSet, state: LocalTimerState.State) {
        self.localTimerSet = localTimerSet
        self.state = state
    }
}
