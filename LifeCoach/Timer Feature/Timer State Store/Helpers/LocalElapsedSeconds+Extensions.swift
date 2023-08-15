import Foundation

extension LocalTimerSet {
    public var toModel: TimerSet {
        TimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
