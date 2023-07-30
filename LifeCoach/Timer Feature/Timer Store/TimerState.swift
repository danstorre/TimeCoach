import Foundation

public struct TimerState: Equatable {
    let elapsedSeconds: TimerSet
    
    public init(elapsedSeconds: TimerSet) {
        self.elapsedSeconds = elapsedSeconds
    }
}
