import Foundation

public protocol LocalTimerStore {
    func retrieve() throws -> LocalTimerState
    func deleteState() throws
    func insert(state: LocalTimerState) throws
}
