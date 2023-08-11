import Foundation

extension TimerEntry {
    public static func createEntry(from currentDate: Date) -> TimerEntry {
        TimerEntry(date: currentDate,
                   timerPresentationValues: .init(starDate: currentDate,
                                                  endDate: currentDate.adding(seconds: 60 * 5), progress: 0),
                   isIdle: false)
    }
}
