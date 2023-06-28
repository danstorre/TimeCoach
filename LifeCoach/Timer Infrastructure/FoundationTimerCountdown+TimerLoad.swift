import Foundation

extension FoundationTimerCountdown: TimerLoad {
    public func loadTime() {
        guard let timeAtSave = timeAtSave else { return }
        let elapsed = CFAbsoluteTimeGetCurrent() - timeAtSave
        elapsedTimeInterval += elapsed.rounded()
        let startDate = currentSet.startDate
        let finishDate = currentSet.endDate
        timerDelivery?(
            .success(LocalElapsedSeconds(elapsedTimeInterval, startDate: startDate, endDate: finishDate))
        )
        startCountdown(completion: timerDelivery ?? { _ in })
        self.timeAtSave = nil
    }
}
