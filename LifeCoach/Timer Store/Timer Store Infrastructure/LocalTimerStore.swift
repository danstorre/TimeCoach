import Foundation

public protocol LocalTimerStore {
    func retrieve() throws -> LocalTimerState
    func deleteState() throws
    func insert(state: LocalTimerState) throws
}

public struct LocalTimerState: Equatable {
    public let localTimerSet: LocalTimerSet
    
    public init(localTimerSet: LocalTimerSet) {
        self.localTimerSet = localTimerSet
    }
}
