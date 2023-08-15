import Foundation
import LifeCoach

extension LocalTimerSet {
    static func pomodoroSet(date: Date) -> LocalTimerSet {
        LocalTimerSet(0, startDate: date, endDate: date.adding(seconds: .pomodoroInSeconds))
    }
    
    static func breakSet(date: Date) -> LocalTimerSet {
        LocalTimerSet(0, startDate: date, endDate: date.adding(seconds: .breakInSeconds))
    }
}
