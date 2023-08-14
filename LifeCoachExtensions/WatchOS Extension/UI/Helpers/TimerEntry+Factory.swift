import Foundation

extension TimerEntry {
    public static func createEntry(from currentDate: Date) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: .init(starDate: currentDate,
                                                  endDate: currentDate.adding(seconds: 60 * 5), progress: 0),
                   isIdle: false)
    }
    
    
    public static func createPomodoroEntry(from currentDate: Date = Date.init()) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: .init(starDate: currentDate,
                                                  endDate: currentDate.adding(seconds: 60 * 25), progress: 0),
                   isIdle: false)
    }
    
    public static func createBreakEntry(from currentDate: Date = Date.init()) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: .init(starDate: currentDate,
                                                  endDate: currentDate.adding(seconds: 60 * 5),
                                                  isBreak: true,
                                                  progress: 0),
                   isIdle: false)
    }
    
    public static func createIdleEntry(from currentDate: Date = Date.init()) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: nil,
                   isIdle: true)
    }
}
