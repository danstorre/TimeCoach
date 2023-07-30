import Foundation

public protocol LocalTimerStore {
    func retrieve() throws -> LocalTimerState
    func deleteState() throws
    func insert(state: LocalTimerState) throws
}

public struct LocalTimerState: Equatable {
    public let localElapsedSeconds: LocalTimerSet
    
    public init(localElapsedSeconds: LocalTimerSet) {
        self.localElapsedSeconds = localElapsedSeconds
    }
}
