import LifeCoach

class LocalTimerStoreSpy: LocalTimerStore {
    private(set) var loadTimerStateCallCount: Int = 0
    
    func retrieve() throws -> LocalTimerState? {
        loadTimerStateCallCount += 1
        return nil
    }
    
    func deleteState() throws {}
    
    func insert(state: LocalTimerState) throws {}
}
