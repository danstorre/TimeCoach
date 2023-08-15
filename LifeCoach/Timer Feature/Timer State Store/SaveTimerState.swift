import Foundation

public protocol SaveTimerState {
    func save(state: TimerState) throws
}
