import Foundation

public struct TimerPresentationValues: Equatable {
    public let starDate: Date
    public let endDate: Date
    public let progress: Float
    public let isBreak: Bool
    
    public init(starDate: Date, endDate: Date, isBreak: Bool, progress: Float) {
        self.starDate = starDate
        self.endDate = endDate
        self.progress = progress
        self.isBreak = isBreak
    }
}
