import Foundation

public enum TimerCountdownSetValueError: Swift.Error {
    case sameDatesNonPermitted
    case endDateIsOlderThanStartDate
}

public protocol TimerCustomStateValues {
    func setElapsedSeconds(_ seconds: TimeInterval)
    func set(startDate: Date, endDate: Date) throws
}
