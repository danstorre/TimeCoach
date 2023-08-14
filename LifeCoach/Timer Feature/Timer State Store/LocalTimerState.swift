import Foundation

public struct LocalTimerState: Equatable {
    public enum State {
        case pause
        case running
        case stop
    }
    public let localTimerSet: LocalTimerSet
    public let state: State
    public let isBreak: Bool
    
    public init(localTimerSet: LocalTimerSet, state: LocalTimerState.State, isBreak: Bool = false) {
        self.localTimerSet = localTimerSet
        self.state = state
        self.isBreak = isBreak
    }
}
