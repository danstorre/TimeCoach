import Foundation

public struct ElapsedSeconds {
    let elapsedSeconds: TimeInterval
    let startingFrom: Date

    public init(
        _ elapsedSeconds: TimeInterval,
        from: Date
    ) {
        self.elapsedSeconds = elapsedSeconds
        self.startingFrom = from
    }
}
