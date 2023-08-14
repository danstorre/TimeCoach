import Foundation

public struct TimerPresentationValues: Equatable {
    public let starDate: Date
    public let endDate: Date
    public let isBreak: Bool
    
    public init(starDate: Date, endDate: Date, isBreak: Bool) {
        self.starDate = starDate
        self.endDate = endDate
        self.isBreak = isBreak
    }
}
