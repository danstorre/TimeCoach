import LifeCoach

class ForegroundSyncSpy: LocalTimerStore, SetableTimer {
    // MARK: - LocalTimerStore
    private(set) var loadTimerStateCallCount: Int = 0
    
    var stubbedInfrastructureLocalTimerState: LocalTimerState?
    
    func retrieve() throws -> LocalTimerState? {
        loadTimerStateCallCount += 1
        return stubbedInfrastructureLocalTimerState
    }
    
    func deleteState() throws {}
    
    func insert(state: LocalTimerState) throws {}
    
    // MARK: - SetableTimer
    private(set) var setableTimerMessagesReceived: [AnyMessage] = []
    
    enum AnyMessage: Equatable, CustomStringConvertible {
        case setStarEndDate(startDate: Date, endDate: Date)
        case set(elapsedSeconds: TimeInterval)
        
        var description: String {
            switch self {
            case .setStarEndDate(let startDate, let endDate): return "command set startDate: \(startDate), endDate: \(endDate)"
            case .set(elapsedSeconds: let elapsed): return "command set elapsedSeconds: \(elapsed)"
            }
        }
    }
    
    func setElapsedSeconds(_ seconds: TimeInterval) {
        setableTimerMessagesReceived.append(.set(elapsedSeconds: seconds))
    }
    
    func set(startDate: Date, endDate: Date) throws {
        setableTimerMessagesReceived.append(.setStarEndDate(startDate: startDate, endDate: endDate))
    }
}
