import Foundation

extension FoundationTimerCountdown: TimerLoad {
    public func loadTime() {
        guard let timeAtSave = timeAtSave else { return }
        let elapsed = CFAbsoluteTimeGetCurrent() - timeAtSave
        
        currentSet = .init(currentSet.elapsedSeconds + elapsed.rounded(), startDate: currentSet.startDate, endDate: currentSet.endDate)
        
        timerDelivery?(
            .success((currentTimerSet, state))
        )
        startCountdown(completion: timerDelivery ?? { _ in })
        self.timeAtSave = nil
    }
}
