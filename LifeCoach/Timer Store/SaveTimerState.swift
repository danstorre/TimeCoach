import Foundation

public struct TimerState {
    let elapsedSeconds: ElapsedSeconds
    
    public init(elapsedSeconds: ElapsedSeconds) {
        self.elapsedSeconds = elapsedSeconds
    }
}

public protocol LocalTimerStore {
    func deleteState() throws
    func insert(state: LocalTimerState) throws
}

public protocol SaveTimerState {
    func save(state: TimerState) throws
}

public class LocalTimer: SaveTimerState {
    private let store: LocalTimerStore
    
    public init(store: LocalTimerStore) {
        self.store = store
    }
    
    public func save(state: TimerState) throws {
        try store.deleteState()
        try store.insert(state: state.local)
    }
}

extension ElapsedSeconds {
    var local: LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}

extension TimerState {
    var local: LocalTimerState {
        LocalTimerState(localElapsedSeconds: elapsedSeconds.local)
    }
}

public struct LocalTimerState: Equatable {
    public let localElapsedSeconds: LocalElapsedSeconds
    
    public init(localElapsedSeconds: LocalElapsedSeconds) {
        self.localElapsedSeconds = localElapsedSeconds
    }
}
