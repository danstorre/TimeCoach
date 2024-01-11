import Foundation

public struct TimerCountDownState {
    public let state: TimerCountdownStateValues
    public let currentTimerSet: TimerCountdownSet
    
    public init(state: TimerCountdownStateValues, currentTimerSet: TimerCountdownSet) {
        self.state = state
        self.currentTimerSet = currentTimerSet
    }
}
