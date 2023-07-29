import Foundation

public struct TimerState {
    let elapsedSeconds: ElapsedSeconds
    
    public init(elapsedSeconds: ElapsedSeconds) {
        self.elapsedSeconds = elapsedSeconds
    }
}

public protocol SaveTimerState {
    func save(state: TimerState) throws
}
