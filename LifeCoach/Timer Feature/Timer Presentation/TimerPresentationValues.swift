import Foundation

public struct TimerPresentationValues: Equatable {
    public let endDate: Date
    public let progress: Float
    
    public init(endDate: Date, progress: Float) {
        self.endDate = endDate
        self.progress = progress
    }
}
