import Foundation

public struct TimerCountDownState {
    public let state: TimerCountdownStateValues
    public let currentTimerSet: LocalTimerSet
    
    public init(state: TimerCountdownStateValues, currentTimerSet: LocalTimerSet) {
        self.state = state
        self.currentTimerSet = currentTimerSet
    }
}
