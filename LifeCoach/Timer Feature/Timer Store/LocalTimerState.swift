import Foundation

public struct LocalTimerState: Equatable {
    public enum State: String {
        case pause
        case running
        case stop
    }
    public let localTimerSet: LocalTimerSet
    let state: State
    
    public init(localTimerSet: LocalTimerSet, state: LocalTimerState.State) {
        self.localTimerSet = localTimerSet
        self.state = state
    }
    
    static func state(from state: TimerState.State) -> LocalTimerState.State {
        switch state {
        case .pause: return .pause
        case .running: return .running
        case .stop: return .stop
        }
    }
}
