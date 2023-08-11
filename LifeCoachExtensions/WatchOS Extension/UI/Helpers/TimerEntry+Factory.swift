import Foundation

extension TimerEntry {
    public static func createEntry(from date: Date) -> TimerEntry {
        TimerEntry(date: date, isIdle: true)
    }
}
