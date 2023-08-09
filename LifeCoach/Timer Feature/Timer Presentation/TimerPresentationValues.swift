import Foundation

public struct TimerPresentationValues: Equatable {
    private let starDate: Date
    public let endDate: Date
    public let progress: Float
    
    public init(starDate: Date, endDate: Date, progress: Float) {
        self.starDate = starDate
        self.endDate = endDate
        self.progress = progress
    }
}
