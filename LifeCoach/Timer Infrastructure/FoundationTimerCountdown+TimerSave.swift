import Foundation

extension FoundationTimerCountdown: TimerSave {
    public func saveTime(completion: @escaping (TimeInterval) -> Void) {
        guard let timer = currentTimer, timer.isValid else { return }
        timeAtSave = CFAbsoluteTimeGetCurrent()
        let elapsedDate = currentSet.startDate.adding(seconds: elapsedTimeInterval)
        
        let remainingSeconds = currentSet.endDate.timeIntervalSince(elapsedDate)
        completion(remainingSeconds)
    }
}
