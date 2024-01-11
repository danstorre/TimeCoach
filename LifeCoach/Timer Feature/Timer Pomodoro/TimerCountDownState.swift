import Foundation

public struct TimerCountDownState {
    public let state: TimerCountdownState
    public let currentTimerSet: LocalTimerSet
    
    public init(state: TimerCountdownState, currentTimerSet: LocalTimerSet) {
        self.state = state
        self.currentTimerSet = currentTimerSet
    }
}
