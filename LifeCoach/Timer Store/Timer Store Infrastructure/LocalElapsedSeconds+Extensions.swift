import Foundation

extension LocalElapsedSeconds {
    public var toElapseSeconds: ElapsedSeconds {
        ElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
