import Foundation

public class TimerGlanceViewModel {
    public enum TimerStatusEvent: Equatable {
        case showIdle
        case showTimerWith(endDate: Date)
    }
    
    private let currentDate: () -> Date
    public var onStatusCheck: ((TimerStatusEvent) -> Void)?
    
    public init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    public func check(timerState: TimerState) {
        switch timerState.state {
        case .pause, .stop:
            onStatusCheck?(.showIdle)
        case .running:
            let endDate = getCurrenTimersEndDate(from: timerState)
            onStatusCheck?(.showTimerWith(endDate: endDate))
        }
    }
    
    private func getCurrenTimersEndDate(from timerState: TimerState) -> Date {
        let currenDate = currentDate()
        let elapsedSeconds = timerState.timerSet.elapsedSeconds
        let startDatePlusElapsedSeconds: Date = timerState.timerSet.startDate.adding(seconds: elapsedSeconds)
        let remainingSeconds = timerState.timerSet.endDate.timeIntervalSinceReferenceDate - startDatePlusElapsedSeconds.timeIntervalSinceReferenceDate
        
        return currenDate.adding(seconds: remainingSeconds)
    }
}
