import Foundation

public protocol LoadTimerState {
    func load() throws -> TimerState
}
