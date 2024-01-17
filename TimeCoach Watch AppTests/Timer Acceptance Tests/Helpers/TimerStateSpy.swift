import Foundation
import LifeCoach

class TimerStateSpy: TimerSave, TimerLoad, LocalTimerStore {
    private(set) var saveTimeCallCount: Int = 0
    private(set) var loadTimeCallCount: Int = 0
    
    private(set) var loadTimerStateCallCount: Int = 0
    
    func saveTime(completion: @escaping (TimeInterval) -> Void) {
        saveTimeCallCount += 1
    }
    
    func loadTime() {
        loadTimeCallCount += 1
    }
    
    func retrieve() throws -> LocalTimerState? {
        loadTimerStateCallCount += 1
        return nil
    }
    
    func deleteState() throws {}
    
    func insert(state: LocalTimerState) throws {}
}
