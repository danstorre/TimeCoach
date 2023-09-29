import Foundation

extension TimerEntry {
    public static func createEntry(from currentDate: Date) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: .init(starDate: currentDate,
                                                  endDate: currentDate.adding(seconds: 60 * 5),
                                                  isBreak: false,
                                                  title: "Pomodoro"),
                   isIdle: false)
    }
    
    
    public static func createPomodoroEntry(from currentDate: Date = Date.init()) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: .init(starDate: currentDate,
                                                  endDate: currentDate.adding(seconds: 60 * 25),
                                                  isBreak: false, title: "Pomodoro"),
                   isIdle: false)
    }
    
    public static func createBreakEntry(from currentDate: Date = Date.init()) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: .init(starDate: currentDate,
                                                  endDate: currentDate.adding(seconds: 60 * 5),
                                                  isBreak: true, title: "Break"),
                   isIdle: false)
    }
    
    public static func createIdleEntry(from currentDate: Date = Date.init()) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: .init(starDate: currentDate,
                                                  endDate: currentDate.adding(seconds: 60 * 25),
                                                  isBreak: false, title: "Click To Start"),
                   isIdle: true)
    }
}
