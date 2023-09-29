import Foundation

public struct TimerPresentationValues: Equatable {
    public let starDate: Date
    public let endDate: Date
    public let isBreak: Bool
    public let title: String
    
    public init(starDate: Date, endDate: Date, isBreak: Bool, title: String) {
        self.starDate = starDate
        self.endDate = endDate
        self.isBreak = isBreak
        self.title = title
    }
}
