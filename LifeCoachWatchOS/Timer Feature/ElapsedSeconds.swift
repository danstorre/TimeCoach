import Foundation

public struct ElapsedSeconds {
    let elapsedSeconds: TimeInterval
    let startDate: Date
    let endDate: Date

    public init(
        _ elapsedSeconds: TimeInterval,
        startDate: Date,
        endDate: Date
    ) {
        self.elapsedSeconds = elapsedSeconds
        self.startDate = startDate
        self.endDate = endDate
    }
}
