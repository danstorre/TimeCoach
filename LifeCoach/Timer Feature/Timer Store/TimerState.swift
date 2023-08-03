import Foundation

public struct TimerState: Equatable {
    public enum State {
        case pause
        case running
        case stop
    }
    let elapsedSeconds: TimerSet
    let state: State
    
    public init(elapsedSeconds: TimerSet, state: TimerState.State) {
        self.elapsedSeconds = elapsedSeconds
        self.state = state
    }
}
