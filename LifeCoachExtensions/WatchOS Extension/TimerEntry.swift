import Foundation
import LifeCoach
import WidgetKit

public struct TimerEntry: TimelineEntry, Equatable {
    public var date: Date
    public var timerPresentationValues: TimerPresentationValues
    public var isIdle: Bool = false
    
    public init(date: Date, timerPresentationValues: TimerPresentationValues, isIdle: Bool) {
        self.date = date
        self.timerPresentationValues = timerPresentationValues
        self.isIdle = isIdle
    }
}
