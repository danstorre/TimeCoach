import Foundation
import LifeCoach

class TimerStateSpy: TimerSave, TimerLoad {
    private(set) var saveTimeCallCount: Int = 0
    private(set) var loadTimeCallCount: Int = 0
    
    func saveTime(completion: @escaping (TimeInterval) -> Void) {
        saveTimeCallCount += 1
    }
    
    func loadTime() {
        loadTimeCallCount += 1
    }
}
