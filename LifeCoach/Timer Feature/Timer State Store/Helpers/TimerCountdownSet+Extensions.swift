import Foundation

extension TimerCountdownSet {
    public var toModel: TimerSet {
        TimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
