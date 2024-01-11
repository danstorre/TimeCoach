import Foundation
import LifeCoach

extension TimerCountdownSet {
    static func pomodoroSet(date: Date) -> TimerCountdownSet {
        TimerCountdownSet(0, startDate: date, endDate: date.adding(seconds: .pomodoroInSeconds))
    }
    
    static func breakSet(date: Date) -> TimerCountdownSet {
        TimerCountdownSet(0, startDate: date, endDate: date.adding(seconds: .breakInSeconds))
    }
}
