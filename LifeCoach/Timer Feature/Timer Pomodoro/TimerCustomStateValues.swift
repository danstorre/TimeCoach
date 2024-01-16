import Foundation

public protocol TimerCustomStateValues {
    func setElapsedSeconds(_ seconds: TimeInterval)
    func set(startDate: Date, endDate: Date) throws
}
