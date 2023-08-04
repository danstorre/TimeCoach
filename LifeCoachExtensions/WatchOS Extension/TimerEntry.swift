import Foundation
import WidgetKit

public struct TimerEntry: TimelineEntry, Equatable {
    public var date: Date
    public var endDate: Date?
    public var isIdle: Bool = false
    
    public init(date: Date, endDate: Date? = nil, isIdle: Bool) {
        self.date = date
        self.endDate = endDate
        self.isIdle = isIdle
    }
}
