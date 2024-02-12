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
    private(set) var startDatesSet: [Date] = []
    private(set) var endDatesSet: [Date] = []
    private(set) var messagesReceived: [AnyMessage] = []
    
    enum AnyMessage: Equatable, CustomStringConvertible {
        case setStarEndDate
        case setElapsedSeconds
        
        var description: String {
            switch self {
            case .setStarEndDate: return "command setStarEndDate"
            case .setElapsedSeconds: return "command setElapsedSeconds"
            }
        }
    }
    
    func setElapsedSeconds(_ seconds: TimeInterval) {
        elapsedSecondsSet.append(seconds)
        messagesReceived.append(.setElapsedSeconds)
    }
    
    func set(startDate: Date, endDate: Date) throws {
        startDatesSet.append(startDate)
        endDatesSet.append(endDate)
        messagesReceived.append(.setStarEndDate)
    }
}
