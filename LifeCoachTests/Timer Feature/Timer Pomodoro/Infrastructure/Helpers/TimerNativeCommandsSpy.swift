import LifeCoach
import Foundation

class TimerNativeCommandsSpy: TimerNativeCommands {
    private var startCompletions = [TimerPulse]()
    func startTimer(completion: @escaping TimerPulse) {
        startCompletions.append(completion)
    }
    
    func invalidateTimer() {
    }
    
    func suspend() {
    }
    
    func resume() {
    }
    
    func completePulse(withIncrementingValue value: TimeInterval, at index: Int = 0) {
        startCompletions[index](value)
    }
}
