import Foundation

public struct LocalTimerState: Equatable {
    public let localTimerSet: LocalTimerSet
    
    public init(localTimerSet: LocalTimerSet) {
        self.localTimerSet = localTimerSet
    }
}
