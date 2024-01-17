import Foundation

public protocol SetableTimer {
    func setElapsedSeconds(_ seconds: TimeInterval)
    func set(startDate: Date, endDate: Date) throws
}
