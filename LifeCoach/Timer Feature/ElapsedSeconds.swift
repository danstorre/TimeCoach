import Foundation

public struct ElapsedSeconds: Equatable {
    public let elapsedSeconds: TimeInterval
    public let startDate: Date
    public let endDate: Date

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
