import Foundation

public class TimerGlanceViewModel {
    public enum TimerStatusEvent: Equatable {
        case showIdle
        case showTimerWith(values: TimerPresentationValues)
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
            let values = getCurrentTimersEndDate(from: timerState)
            
            onStatusCheck?(.showTimerWith(values: values))
        }
    }
    
    private func getCurrentTimersEndDate(from timerState: TimerState) -> TimerPresentationValues {
        let currentDate = currentDate()
        let elapsedSeconds = timerState.timerSet.elapsedSeconds
        let startDatePlusElapsedSeconds: Date = timerState.timerSet.startDate.adding(seconds: elapsedSeconds)
        let remainingSeconds = timerState.timerSet.endDate.timeIntervalSinceReferenceDate - startDatePlusElapsedSeconds.timeIntervalSinceReferenceDate
        
        let totalTime = timerState.timerSet.endDate.timeIntervalSinceReferenceDate - timerState.timerSet.startDate.timeIntervalSinceReferenceDate
        
        return TimerPresentationValues(
            starDate: currentDate - remainingSeconds,
            endDate: currentDate.adding(seconds: remainingSeconds),
            progress: Float(remainingSeconds/totalTime))
    }
}
