import LifeCoach

class ForegroundSyncSpy: LocalTimerStore, SetableTimer {
    // MARK: - LocalTimerStore
    private(set) var loadTimerStateCallCount: Int = 0
    
    var stubbedLoadedLocalTimerState: LocalTimerState?
    
    func retrieve() throws -> LocalTimerState? {
        loadTimerStateCallCount += 1
        return stubbedLoadedLocalTimerState
    }
    
    func deleteState() throws {}
    
    func insert(state: LocalTimerState) throws {}
    
    // MARK: - SetableTimer
    private(set) var elapsedSecondsSet: [TimeInterval] = []
    
    func setElapsedSeconds(_ seconds: TimeInterval) {
        elapsedSecondsSet.append(seconds)
    }
    
    func set(startDate: Date, endDate: Date) throws {}
}
