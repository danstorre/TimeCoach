import Foundation

extension LocalTimerSet {
    public var toElapseSeconds: TimerSet {
        TimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
