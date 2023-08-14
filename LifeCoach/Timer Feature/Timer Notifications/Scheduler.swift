import Foundation

public protocol Scheduler {
    func setSchedule(at scheduledDate: Date, isBreak: Bool) throws
}
