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
    private(set) var startDatesSet: [Date] = []
    private(set) var endDatesSet: [Date] = []
    private(set) var setableTimerMessagesReceived: [AnyMessage] = []
    
    enum AnyMessage: Equatable, CustomStringConvertible {
        case setStarEndDate
        case set(elapsedSeconds: TimeInterval)
        
        var description: String {
            switch self {
            case .setStarEndDate: return "command setStarEndDate"
            case .set(elapsedSeconds: let elapsed): return "command set elapsedSeconds: \(elapsed)"
            }
        }
    }
    
    func setElapsedSeconds(_ seconds: TimeInterval) {
        setableTimerMessagesReceived.append(.set(elapsedSeconds: seconds))
    }
    
    func set(startDate: Date, endDate: Date) throws {
        startDatesSet.append(startDate)
        endDatesSet.append(endDate)
        setableTimerMessagesReceived.append(.setStarEndDate)
    }
}
