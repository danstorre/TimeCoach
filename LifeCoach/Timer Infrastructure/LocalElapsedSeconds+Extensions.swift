import Foundation

extension LocalElapsedSeconds {
    var toElapseSeconds: ElapsedSeconds {
        ElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
